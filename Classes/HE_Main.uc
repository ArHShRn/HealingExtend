//=============================================================================
// Healing Extend Mutator Main Part
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.3
// - New ChatController forked from RPW, easier usage.
// - Removed Dynamic Settings, will develop later.
//
// Last Update Date Jan.26th 2018
//=============================================================================
class HE_Main extends KFMutator
	config(HE_Main);

//**************************
//*  System Configs
//**************************
//Mutator Version Info
var config HEVersionInfo	HEVI;
var HEVersionInfo			Editable_HEVI;

//System Variable Configs
var config bool				bEnableHE;
var config float			fCurrentRegenRate;
var config bool				bAllowOverClocking;	
var config bool				bInitedConfig;
var config bool				bRecoverAmmo;	
var config bool				bEnableAAR_Headshots;
var config bool				bGetDosh;
var config float			DecreModifier; //For health n armor decreament

//System Variables		
var	bool					bInNormalTime;				
var float					fLastHSC; // a players last headshot count
var HE_ChatController		HECC;
var bool					bCreatedBH;

//**************************
//*  Gameplay Configs
//**************************
var array<HEPlayer>			Players; //Cached Players
var int						PlayerNumber;
var STraderItem				TI;
	 
//**************************
//*  Common Settings
//**************************
var config int				HealthHealingAmount;
var config int				ArmourHealingAmount;
var config int				AmmoRecoverAmout;
var config int				BonusDosh;
var config int				OverclockLimitHealth;
var config int				OverclockLimitArmour;

//*************************************************
//*  Initialization
//*************************************************
//1.PreBeginPlay, before game starts
//	Init mutator config values
//	Create empty HEPlayer instance
function PreBeginPlay()
{
	if(!bInitedConfig)
	{
		`log("[HE::PreBeginPlay]Init Basic Mutator Values...");
		InitBasicMutatorValues();
		SaveConfig();
	}
	
	super.PreBeginPlay();
}
//2.NotifyLogin, when player enters game
//	Add him into HEPlayer array to manage him
function NotifyLogin(Controller NewPlayer)
{
	super.NotifyLogin(NewPlayer);
}
//3.PostBeginPlay, after game starts
function PostBeginPlay()
{	
	SetTimer(1.1f, true, nameof(SetBH));
	super.PostBeginPlay();
}
//4.ModifyPlayer, when player's pawn is created
//	Modify HealthRegenRate
//	ReInitPlayersArry, because he may have died last wave
function ModifyPlayer(Pawn Other)
{	
	//Instant Healing Stuffs
	local KFPawn_Human KFPH;
	KFPH=KFPawn_Human(Other);
	
	if(bEnableHE)
		KFPH.HealthRegenRate=(1/fCurrentRegenRate);
	`log("[HE::ModifyPlayer]HealthRegenRate Set to "$KFPH.HealthRegenRate);

	//Re-initialize Players Array, Check if he exists in the game
	//Attention: When there's a player exited the game, dead HEP will be removed
	//			Turn to AddHimIntoPlayers(Other) directly
	if(!ReInitPlayersArry(Other))
	//Add this player in to Players array if he's new in this game
	//	Or he's been deleted after a player exited while he's dead
		AddHimIntoPlayers(Other);
	
	//Testing Rep, should be commented in release ver
	//Spawn(class'HE_RepTest', Other.Controller);
		
	super.ModifyPlayer(Other);
}
//5.NotifyLogout, when player exits
//	Delete him out of HEPlayer array
function NotifyLogout(Controller Exiting)
{	
	NotifyPlayerExits(KFPlayerController(Exiting));
	super.NotifyLogout(Exiting);
}


//Initialize basic config default values used in the mutator
//Author recommended values, plz do not edit
function InitBasicMutatorValues()
{
	//Muatator Version Info
	Editable_HEVI.ThisMutatorName="Healing Extend Main Part";
	Editable_HEVI.AuthorNickname="ArHShRn";
	Editable_HEVI.AuthorSteamcommunityURL="http://steamcommunity.com/id/ArHShRn/";
	Editable_HEVI.Version="Release 1.1.3";
	Editable_HEVI.LastUpdate="Jan.26th 2018 09:22 PM";
	HEVI=Editable_HEVI;
	
	//Mutator Config Variable
	bInitedConfig=True;
	
	//Mutator Mechanism
	bEnableHE=True;
	bGetDosh=True;
	bRecoverAmmo=False;
	bAllowOverClocking=True;
	bEnableAAR_Headshots=True;

	//Gameplay Settings
	BonusDosh=37; 
	AmmoRecoverAmout=1;
	fCurrentRegenRate=40.0;
	HealthHealingAmount=3; 
	ArmourHealingAmount=5;
	OverclockLimitHealth=150; 
	OverclockLimitArmour=175;
	DecreModifier=0.2f;
}
//To add a new player into Players Array
//if player is died last wave, update his info to the array
function AddHimIntoPlayers(Pawn P)
{
	local HEPlayer				instance;
	local KFPlayerController	PlayerKFPC;
	local KFPawn_Human			PlayerKFPH;
	
	PlayerKFPC=KFPlayerController(P.Controller);
	PlayerKFPH=KFPawn_Human(P);
	
	if(PlayerKFPC==None || PlayerKFPH==None) //if he's not Human, return
		return;

	instance.UniqueID=PlayerKFPC.GetOnlineSubsystem().UniqueNetIdToString(PlayerKFPC.PlayerReplicationInfo.UniqueId);
	`log("[HEMain]"$PlayerKFPC.PlayerReplicationInfo.PlayerName$" UID="$instance.UniqueID);
	instance.KFPC=PlayerKFPC;
	
	//Should be re-inited every time the ModifyPlayer is called(e.g, he died last wave)
	instance.KFPH=PlayerKFPH;//Will be invalid when he died last wave
	
	instance.LastPerk=PlayerKFPC.GetPerk().GetPerkClass();
	
	//Spawn Player's HUDManager and set his HUD
	//First spawn a manager and set owner to this Pawn's player
	instance.HUDManager = Spawn(class'HE_HUDManager', instance.KFPC);
	`log("[HEMain]Spawned a new HUDManager="$instance.HUDManager.Name);
	instance.HUDManager.ClientSetHUD();
	instance.HUDManager.bStartGame=True;
	
	////Spawn Trader Manager
	//instance.TraderManager = Spawn(class'HE_TraderManager', Players[PlayerIndex].KFPC);
	//`log("[HEMain]Spawned a new HE_TraderManager="$Players[PlayerIndex].TraderManager.Name);
	//instance.TraderManager.StartSyncItem();
	
	//Set Delta and Recover Pool
	instance.HealthDecrement=0.f;
	instance.ArmorDecrement=0.f;
	
	instance.bIsEpt=False;
	
	Players.AddItem(instance);
	Players[Players.Length-1].index=Players.Length-1;
} 
//Re-initialize Players Array
//Check if there's player died last wave
//Return true if find and re-init him
function bool ReInitPlayersArry(Pawn P)
{
	local int						InGamePlayerIndex;
	local string					UID;
	local bool						bIsDiedLastWave;
	local KFPawn_Human				PlayerKFPH;
	local KFPlayerController    	PlayerKFPC;
	local HEPlayer					TargetHEP;

	InGamePlayerIndex=0;
	bIsDiedLastWave=False;
		
	PlayerKFPH=KFPawn_Human(P);
	PlayerKFPC=KFPlayerController(P.Controller);
	UID=PlayerKFPC.GetOnlineSubsystem().UniqueNetIdToString(PlayerKFPC.PlayerReplicationInfo.UniqueId);
	`log("[HEMain::ReInitPlayersArry]"$PlayerKFPC.PlayerReplicationInfo.PlayerName$" UID="$UID);
	//Check Players array to find him
	ForEach Players(TargetHEP)
	{
		`log("[HEMain::ReInitPlayersArry]"$TargetHEP.KFPC.PlayerReplicationInfo.PlayerName$" UID="$TargetHEP.UniqueID);
		if(UID == TargetHEP.UniqueID)
		{
			InGamePlayerIndex = TargetHEP.Index;
			bIsDiedLastWave = True;
			break;
			`log("[HEMain::ReInitPlayersArry]UID Matched.");
		}
	}
		
	//If player died last wave, update Player Info
	//HUD, HUDManager, TraderManager, doesn't need respawning again
	if(bIsDiedLastWave)
	{		
		//Update his new KFPH into the array
		Players[InGamePlayerIndex].KFPC=PlayerKFPC;
		Players[InGamePlayerIndex].KFPH=PlayerKFPH;
		
		//Set its perk class
		Players[InGamePlayerIndex].LastPerk=PlayerKFPC.GetPerk().GetPerkClass();
		
		//Set Delta n Recover Pool
		Players[InGamePlayerIndex].HealthDecrement=0.f;
		Players[InGamePlayerIndex].ArmorDecrement=0.f;
		
		//Broadcast DEBUG
		foreach WorldInfo.AllControllers(class'KFPlayerController', PlayerKFPC)
			BroadcastDebug(PlayerKFPC);
			
		Players[InGamePlayerIndex].HUDManager.ClientAddChatLine("YOU DIED LAST WAVE", "#B22222"); //Firebrick
		Players[InGamePlayerIndex].HUDManager.ClientAddChatLine("KILLER: "$class'HE_Assistance'.static.ConvertMonsterClassName(PlayerKFPC.PWRI.ClassKilledByLastWave), "#B22222"); //Firebrick
		return true;
	}
	return false;
}
//Delete him from HEPlayer array and re-assign each instance's location
function NotifyPlayerExits(KFPlayerController KFPC)
{
	local HEPlayer	TargetHEP;
	local string		UID;
	local int		PIndex;
	
	PIndex = -1;
	
	if(KFPC == None)
	{
		`log("[HEMain]WARNING: Ghost Detected!");
		return;
	}
	
	
	//1.Find and remove him
	UID=KFPC.GetOnlineSubsystem().UniqueNetIdToString(KFPC.PlayerReplicationInfo.UniqueId);
	`log("[HEMain::NotifyPlayerExits]"$KFPC.PlayerReplicationInfo.PlayerName$" UID="$UID);
	ForEach Players(TargetHEP)
	{
		`log("[HEMain::NotifyPlayerExits]"$KFPC.PlayerReplicationInfo.PlayerName$" UID="$TargetHEP.UniqueID);
		if(TargetHEP.UniqueID == UID)
		{
			`log("[HEMain]ACTION: Exited player KFPC find in Players Array. Current Length "$Players.Length);
			`log("[HEMain::NotifyPlayerExits]UID Matched");
			PIndex = TargetHEP.Index;
			Players.RemoveItem(Players[PIndex]);
			`log("[HEMain]ACTION: Exited player removed from Players Array. PIndex "$PIndex$", Current Length "$Players.Length);
			break;
		}
	}
	//2.Re-assign living player's index
	//If P4 is removed, then the array is like this:
	//Index of array   :  0   1   2   3   4
	//Index in HEPlayer:  0   1   2   3   5
	//KFPC             :  P1  P2  P3  P5  P6
	//KFPH             :  PH1 PH2 PH3 PH5 PH6
	//Re-assign their index and PlayerNumber
	PIndex = 0;
	ForEach Players(TargetHEP)
	{
		if(TargetHEP.Index == PIndex)
			TargetHEP.HUDManager.ClientAddChatLine("Your HEPosition Maintains.");
		else
		{
			TargetHEP.Index = PIndex;
			TargetHEP.HUDManager.ClientAddChatLine("HEPosition Changed To "$PIndex);
			TargetHEP.HUDManager.ClientPrint("A Player Exited Or You Died Last Wave, Your Pos In HE Is Changed", true);
			TargetHEP.HUDManager.ClientPrint("Check If HE Works After A Player Has Exited Or You Died", true);
			TargetHEP.HUDManager.ClientPrint("If There's Something Wrong, Please Report Bug In Following Methods", true);
			TargetHEP.HUDManager.ClientPrint("@GITHUB:https://github.com/ArHShRn/HealingExtend/", true);
			TargetHEP.HUDManager.ClientPrint("@EMAIL:drancickphysix@yahoo.com", true);
			TargetHEP.HUDManager.ClientPrint("DO NOT Forget To Attach Runtime Logs", true);
			TargetHEP.HUDManager.ClientPrint("Thank You For Your Time :D", true);
		}
		++PIndex;
	}
}

//Player Message
function PlayerMsg(KFPlayerController KFPC, coerce string msg, optional string MsgColor="42bbbc", optional name Type = 'ChatBox')
{
	local HEPlayer HEP;
	foreach Players(HEP)
	{
		if(HEP.KFPC == KFPC)
		{
			if(Type == 'ChatBox')
				HEP.HUDManager.ClientAddChatLine(msg, MsgColor);
			else if(Type == 'Console')
				HEP.HUDManager.ClientPrint(msg, true);
			else if(Type == 'Center')
				HEP.HUDManager.ClientHUDMessage(msg);
			return;
		}
	}
}
//Global Player Message
function GlobalMsg(coerce string msg, optional string MsgColor="42bbbc", optional name Type = 'ChatBox')
{
	local HEPlayer HEP;
	foreach Players(HEP)
	{
		if(Type == 'ChatBox')
			HEP.HUDManager.ClientAddChatLine(msg, MsgColor);
		else if(Type == 'Console')
			HEP.HUDManager.ClientPrint(msg, true);
		else if(Type == 'Center')
			HEP.HUDManager.ClientHUDMessage(msg);
	}
}
//Broadcast function
function Broadcast(PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg) 
{
	local string MsgHead, Param;
	local array<String> splitbuf;
	
	ParseStringIntoArray(Msg,splitbuf," ",true);
	MsgHead = splitbuf[0];
	Param = splitbuf[splitbuf.Length-1];
	switch(MsgHead) 
	{
		case "!HESys":
			if(!bEnableHE)
			{
				GlobalMsg("[HealingExtend System Disabled]");
				break;
			}
			GlobalMsg("[HealingExtend System]");
			GlobalMsg("Best For CD Usage :D");
			GlobalMsg("MutVer:"$HEVI.Version);
			GlobalMsg("LastUpdate:"$HEVI.LastUpdate);
			GlobalMsg("--[HealingExtend System]--",,'Console');
			GlobalMsg("Best For CD Usage :D",,'Console');
			GlobalMsg("MutVer:"$HEVI.Version,,'Console');
			GlobalMsg("LastUpdate:"$HEVI.LastUpdate,,'Console');
			break;
		case "!HEBuy":
			if(Param == MsgHead)
			{
				BroadcastBuyHelp(KFPlayerController(Receiver));
				break;
			}
			BuyPlayerWeapon(KFPlayerController(Receiver), Param);
			break;
		case "!HEInfo":
			if(!bEnableHE)
			{
				GlobalMsg("[HealingExtend System Disabled]");
				break;
			}
			GlobalMsg("[HealingExtend Config]");
			GlobalMsg("Current HRRate:"$fCurrentRegenRate$" Per second");
			GlobalMsg("Decre Mdf:"$DecreModifier);
			GlobalMsg("H / AG Ammount:"$HealthHealingAmount$" / "$ArmourHealingAmount);
			GlobalMsg("DoshBonus Ammount:"$BonusDosh);
			GlobalMsg("MOH / MOA:"$OverclockLimitHealth$" / "$OverclockLimitArmour);
			GlobalMsg("RecoverAmmo:"$bRecoverAmmo);
			GlobalMsg("--[HealingExtend Config]--",,'Console');
			GlobalMsg("Current Health Regeneration Rate:"$fCurrentRegenRate$" Per second",,'Console');
			GlobalMsg("Health and Armor Decrement Modifier:"$DecreModifier,,'Console');
			GlobalMsg("Health / Armor gain Ammount:"$HealthHealingAmount$" / "$ArmourHealingAmount,,'Console');
			GlobalMsg("Dosh Bonus Ammount:"$BonusDosh,,'Console');
			GlobalMsg("Maximum Overclocked Health / Maximum Overclocked Armor:"$OverclockLimitHealth$" / "$OverclockLimitArmour,,'Console');
			GlobalMsg("Is Recovering Ammo:"$bRecoverAmmo,,'Console');
			break;
		case "!HEDebug":
			BroadcastDebug(KFPlayerController(Receiver));
			break;
		case "!TK18039":
			GlobalMsg("TK18039 Meow Meow Meow ~ ¤Å£þ3£þ¤Å",,'Center');
			break;
		case "!Fuck":
		case "!Fvck":
		case "!Fk":
			GlobalMsg("WHAT ARE YOU TALKING ABOUT ?","#b2222");
			GlobalMsg("DOSH -25,000","#b2222");
			KFPlayerReplicationInfo(KFPlayerController(Receiver).PlayerReplicationInfo).AddDosh(-25000);
			break;
	}
}
//Broadcasr Buy Help
function BroadcastBuyHelp(KFPlayerController KFPC)
{
	PlayerMsg(KFPC, "--HE Quick Purchase Help--");
	PlayerMsg(KFPC, "=Current Supported Weapons=");
	PlayerMsg(KFPC, "M14EBR: !HEBuy M14/M14EBR");
	PlayerMsg(KFPC, "AK12:	 !HEBuy AK12");
	PlayerMsg(KFPC, "SCAR:   !HEBuy SCAR");
	PlayerMsg(KFPC, "HMT-401:!HEBuy 401");
	PlayerMsg(KFPC, "M4:     !HEBuy M4");
	PlayerMsg(KFPC, "AA12:   !HEBuy AA12");
	PlayerMsg(KFPC, "P90:    !HEBuy P90");
	PlayerMsg(KFPC, "Kriss:  !HEBuy Kriss");
	PlayerMsg(KFPC, "HK-UMP: !HEBuy UMP/HK-UMP/HKUMP");
	PlayerMsg(KFPC, "--HE Quick Purchase Help--");
}
//Broadcasr Debug Info
function BroadcastDebug(KFPlayerController KFPC)
{
	local HEPlayer HEP;
	PlayerMsg(KFPC,"[Healing Extend Debug Info Full]",,'Console');
	//1.Players Array Details In Console
	PlayerMsg(KFPC,"----Players Array Details",,'Console');
	ForEach Players(HEP)
	{
		PlayerMsg(KFPC,"  --Player["$HEP.Index$"]",,'Console');
		PlayerMsg(KFPC,"    PlayerName="$HEP.KFPC.PlayerReplicationInfo.PlayerName,,'Console');
		PlayerMsg(KFPC,"    PlayerUID="$HEP.UniqueID,,'Console');
		PlayerMsg(KFPC,"    PlayerKFPC="$HEP.KFPC.Name,,'Console');
		PlayerMsg(KFPC,"    PlayerKFPH="$HEP.KFPH.Name,,'Console');
	}
	//2.Network status
}

//Buy plyaer a weapon
function BuyPlayerWeapon(KFPlayerController KFPC, string ChatMsg, optional bool bFillAmmo = True)
{
	local int				WeapPrice;
	local byte				TraderIndex;
	local int				FillDosh;
	local int				AmountPurchased;
	local bool				bFindWeap;
	local STraderItem		WeaponItem;
	local class<KFWeapon>	KFW;
	local KFWeapon			KFWObj;
	local Inventory			Inv;
	
	if(ChatMsg == "!HEBuy") return;
	
	WeapPrice=0;
	TraderIndex=0;
	bFindWeap=false;
	
	//0.Check wave state
	if(MyKFGI.IsWaveActive())
	{
		//PlayerMsg(KFPC, "You Can't Buy It Now!","#B22222",);
		return;
	}
	
	//1.Convert ChatMsg
	switch(ChatMsg)
	{
		case "M14":
		case "M14EBR":
			KFW=class'KFWeap_Rifle_M14EBR';
			WeapPrice=1100;
			TraderIndex=43;
			break;
		case "AK12":
			KFW=class'KFWeap_AssaultRifle_AK12';
			WeapPrice=1100;
			TraderIndex=9;
			break;
		case "SCAR":
			KFW=class'KFWeap_AssaultRifle_Scar';
			WeapPrice=1500;
			TraderIndex=10;
			break;
		case "401":
			KFW=class'KFWeap_AssaultRifle_Medic';
			WeapPrice=1500;
			TraderIndex=20;
			break;
		case "M4":
			KFW=class'KFWeap_Shotgun_M4';
			WeapPrice=1100;
			TraderIndex=32;
			break;
		case "AA12":
			KFW=class'KFWeap_Shotgun_AA12';
			WeapPrice=1500;
			TraderIndex=33;
			break;
		case "P90":
			KFW=class'KFWeap_SMG_P90';
			WeapPrice=1100;
			TraderIndex=50;
			break;
		case "Kriss":
			KFW=class'KFWeap_SMG_Kriss';
			WeapPrice=1500;
			TraderIndex=51;
			break;
		case "UMP":
		case "HK-UMP":
		case "HKUMP":
			KFW=class'KFWeap_SMG_HK_UMP';
			WeapPrice=1200;
			TraderIndex=54;
			break;
		default:
			PlayerMsg(KFPC, "Weapon Not Support","#B22222",);
			return;
	}
	`log("[HEMain]"$KFPC.PlayerReplicationInfo.PlayerName$" Is Pending KFWeapon "$KFW.Name);
	
	//2.Already have?
	for (Inv = KFPC.GetPurchaseHelper().MyKFIM.InventoryChain; Inv != None; Inv = Inv.Inventory)
	{
		if(Inv.Class == KFW)
		{
			//PlayerMsg(KFPC, "You Owned This Weapon",,);
			bFindWeap=true;
			break;
		}
    }
    if(bFindWeap) return;
	
	//3.No money?
	if(KFPC.PlayerReplicationInfo.Score < WeapPrice)
	{
		PlayerMsg(KFPC, "Out Of Dosh "$KFPC.PlayerReplicationInfo.Score$"/"$WeapPrice);
		return;
	}
	`log("[HEMain]"$KFPC.PlayerReplicationInfo.PlayerName$" Affords Current Buy Price="$ WeapPrice );
	
	//4.Simulating trader buying process
		//4.1 Initialize
	KFPC.GetPurchaseHelper().Initialize();
		//4.2 Simulating trader-open state
	KFPC.GetPurchaseHelper().MyKFIM.bServerTraderMenuOpen=true;
			//4.3.1 Standalone game sound playing
	if(WorldInfo.NetMode == NM_Standalone)
		KFPC.MyGFxManager.PlaySoundFromTheme('TRADER_OPEN_MENU', 'UI');
			//4.3.2 Online session sound playing
	if(WorldInfo.NetMode == NM_DedicatedServer && Role == Role_Authority)
		GetHEP(KFPC).HUDManager.ClientPlaySoundFromTheme('TRADER_OPEN_MENU', 'UI');
		//4.4 Buy Weapon
	KFPC.GetPurchaseHelper().MyKFIM.ServerBuyWeapon(TraderIndex);
		//4.5 Simulating trader-closed state
	KFPC.GetPurchaseHelper().MyKFIM.ServerCloseTraderMenu();
		//4.6 Check and give ammo
		//AmmoNeed is SpareAmmoCapacity[0]-SpareAmmoOwned
	if(bFillAmmo)
	{
		//Give him enough dosh to fill ammo
		AmountPurchased=KFWeapon(KFPC.Pawn.Weapon).GetMaxAmmoAmount(0)-KFWeapon(KFPC.Pawn.Weapon).SpareAmmoCount[0];
		FillDosh= AmountPurchased 
			/ KFWeapon(KFPC.Pawn.Weapon).MagazineCapacity[0] 
			* KFGameReplicationInfo( WorldInfo.GRI ).TraderItems.SaleItems[TraderIndex].WeaponDef.default.AmmoPricePerMag;
		if(KFPC.PlayerReplicationInfo.Score <= FillDosh)
		{
			PlayerMsg(KFPC, "Horzine Tech LTD. Helps With Your Money");
			KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).AddDosh( -KFPC.PlayerReplicationInfo.Score );
		}
		else
			KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).AddDosh( -FillDosh );
			
		////Then buy ammo full
		//KFPC.GetPurchaseHelper().MyKFIM.BuyAmmo
		//(
			//AmountPurchased,
			//0,
			//TraderIndex,
			//false
		//);
		ForEach KFPC.Pawn.InvManager.InventoryActors(class'KFWeapon', KFWObj)
		{	
			KFWObj.AmmoCount[0] = KFWObj.MagazineCapacity[0];
			KFWObj.AddAmmo(KFWObj.GetMaxAmmoAmount(0));
			//KFWObj.AddSecondaryAmmo(KFWObj.MagazineCapacity[1]);
		}
	}
	KFPC.GetPurchaseHelper().MyKFIM.UpdateHUD();
}

//Stop broadcasting
function bool StopBroadcast(string Msg) {
	local string MsgHead;
	local array<String> splitbuf;
	ParseStringIntoArray(Msg,splitbuf," ",true);
	MsgHead = splitbuf[0];
	switch(MsgHead) {
		case "!HEBuy":
		case "!HETestStopBroadcast":
			return True;
	}
	return false;
}
//Set new BroadcastHandler
function SetBH() 
{
	if (HE_ChatController(MyKFGI.BroadcastHandler)==None) 
	{
		HECC=spawn(class'HE_ChatController');
		HECC.InitHEClass(Self);
		`log("[HEMain]Spawn HE_ChatController to "$MyKFGI.MyKFGRI);
	 	ClearTimer(nameof(SetBH));
	}
}

//Get HEP
function HEPlayer GetHEP(KFPlayerController KFPC)
{
	local HEPlayer HEP;
	foreach Players(HEP)
	{
		if(HEP.KFPC == KFPC)
			return HEP;
	}
	return HEP;
}
//*************************************************
//*  Main Func
//*************************************************
//Headshot Recover Function
//Version 1.1.1
//-OC recover ammount will be added into recover pool
function HeadshotRecover(int i)
{
	if(bAllowOverClocking)
	{
		//Health
		if(Players[i].KFPC.Pawn.Health > Players[i].KFPC.Pawn.HealthMax)
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+2*HealthHealingAmount, OverclockLimitHealth);
		else
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+HealthHealingAmount, OverclockLimitHealth);
			
		//Armor
		if(Players[i].KFPH.Armor > Players[i].KFPH.MaxArmor)
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+2*ArmourHealingAmount, OverclockLimitArmour);
		else
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+ArmourHealingAmount, OverclockLimitArmour);
	}
	else
	{
		//Health default state
		Players[i].KFPC.Pawn.Health=Min
		(
			Players[i].KFPC.Pawn.Health+HealthHealingAmount, 
			Players[i].KFPC.Pawn.HealthMax
		);
		
		//Armor default state
		Players[i].KFPH.Armor=Min
		(
			Players[i].KFPH.Armor+ArmourHealingAmount,
			Players[i].KFPH.MaxArmor
		);
	}
}
//Tick Mutator
//i is from 1
function TickMutRecover(int i, float DeltaTime)
{	
	if(Players[i].KFPC == None 
		|| Players[i].KFPC.Pawn == None 
		|| Players[i].KFPH == None
		)
		return;
	
	//Tick overclock armor and health Decrement
	//Check health and armor state
	//Only decrease when overclocks
	if(Players[i].KFPC.Pawn.Health > Players[i].KFPC.Pawn.HealthMax)
	{
		Players[i].HealthDecrement += DecreModifier * HealthHealingAmount * DeltaTime;
		if(Players[i].HealthDecrement >= 1.f)
		{
			--Players[i].KFPC.Pawn.Health;
			Players[i].HealthDecrement -= 1.f;
		}
	}
	if(Players[i].KFPH.Armor > Players[i].KFPH.MaxArmor)
	{
		Players[i].ArmorDecrement += DecreModifier * ArmourHealingAmount * DeltaTime;
		if(Players[i].ArmorDecrement >= 1.f)
		{
			--Players[i].KFPH.Armor;
			Players[i].ArmorDecrement -= 1.f;
		}
	}
	
	//Set his pShotTarget to his ShotTarget
	Players[i].pShotTarget=Players[i].KFPC.ShotTarget;
		
	//If he's not shooting a target, continue to check next player
	if(Players[i].pShotTarget == None)
		return;
		
	//KFPawn_Monster victim he owns is his monster shooting target
	Players[i].KFPM_Victim=KFPawn_Monster(Players[i].pShotTarget);
	
	//If he's not shooting a monster (like shooting a KFHealing_Dart to teammates)
	//Or he's shooting at a dead monster
	//Continue to check next player
	if(Players[i].KFPM_Victim==None)
		return;
	
	//If his KFPM_Victim's head health <=0, which means its head is been shot and dismembered
	if(Players[i].KFPM_Victim.HitZones[HZI_HEAD].GoreHealth <= 0 && Players[i].pShotTarget != Players[i].LastTarget)
	{
		//Last Target
		Players[i].LastTarget = Players[i].pShotTarget;
		
		//Add Dosh
		if(bGetDosh)
			KFPlayerReplicationInfo(Players[i].KFPC.PlayerReplicationInfo).AddDosh(BonusDosh);
				
		//Recover Func
		HeadshotRecover(i);
			
		//Decap_Detection Ammo Recovery
		if(bRecoverAmmo && !bEnableAAR_Headshots)
		{
			//Get Player's Weap
			Players[i].KFWeap=KFWeapon(Players[i].KFPC.Pawn.Weapon);
			if(Players[i].KFWeap!=None)
			{
				Players[i].KFWeap.AmmoCount[0]=Min
				(
					Players[i].KFWeap.AmmoCount[0]+AmmoRecoverAmout, 
					Players[i].KFWeap.MagazineCapacity[0]
				);
				Players[i].KFWeap.ClientForceAmmoUpdate(Players[i].KFWeap.AmmoCount[0], Players[i].KFWeap.SpareAmmoCount[0]);
				Players[i].KFWeap.bNetDirty=True;
			}
		}
	}
	
	//AAR_Dection Ammo Recovery
	if(bRecoverAmmo && bEnableAAR_Headshots)
	{
		Players[i].KFWeap=KFWeapon(Players[i].KFPC.Pawn.Weapon);
		if(Players[i].fLastHSC!=Players[i].KFPC.PWRI.VectData1.X)
		{
			Players[i].KFWeap.AmmoCount[0]+=Players[i].KFPC.PWRI.VectData1.X-Players[i].fLastHSC;
			Players[i].KFWeap.AmmoCount[0]=Min
			(
				Players[i].KFWeap.AmmoCount[0], 
				Players[i].KFWeap.MagazineCapacity[0]
			);
			Players[i].KFWeap.ClientForceAmmoUpdate(Players[i].KFWeap.AmmoCount[0], Players[i].KFWeap.SpareAmmoCount[0]);
			Players[i].KFWeap.bNetDirty=True;
			Players[i].fLastHSC=Players[i].KFPC.PWRI.VectData1.X;
		}
	}
	
	//Record in ZedTime
	bInNormalTime=True;
	
	if(`IsInZedTime(self))
	{
		//If it's in zedtime then we call zedtime-actions
		//	and let the boolean value know that we're in zedtime
		bInNormalTime=False;
		
		//TO-DO: Functions called in ZedTime
	}
	
	//If the boolean tells that we're in zedtime(not in normal time)
	//	then this normal-time-action shouldn't be acted
	if(bInNormalTime)
	{
		//TO-DO: Functions called in NormalTime
	}
}

//*************************************************
//*  Tick Time Update
//*************************************************
//Tick event
Event Tick(float DeltaTime)
{
	local HEPlayer HEP;
	
	//ForEach Player in Players Array
	foreach Players(HEP)
	{
		if(!HEP.bIsEpt && bEnableHE)
			TickMutRecover(HEP.Index, DeltaTime);
	}
		
	super.Tick(DeltaTime);
}

defaultproperties
{
	PlayerNumber=0
	bInNormalTime=True
	bCreatedBH=False
}
