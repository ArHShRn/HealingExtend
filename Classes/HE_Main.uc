//=============================================================================
// Healing Extend Mutator Main Part
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.2
// -Add player health pool, to gradually recover bonus HP and Armor
//
// Last Update Date Oct.11th 2017
//=============================================================================
class HE_Main extends KFMutator
	DependsOn(HE_DataStructure)
	config(HE_Main);

//**************************
//*  System Configs
//**************************
//Mutator Version Info
var config HEVersionInfo	HEVI;
var HEVersionInfo			Editable_HEVI;

//Rep
var HEConfig				HE_MainConfig;

//System Variable Configs
var config float			fCurrentRegenRate;
var config bool				bAllowOverClocking;	
var config bool				bInitedConfig;
var config bool				bRecoverAmmo;	
var config bool				bEnableAAR_Headshots;
var config bool				bGetDosh;
var float					DeltaModifier;

//System Variables
//var HE_ChatController		ChatController;				
var	bool					bInNormalTime;				
var float					fLastHSC;

//**************************
//*  Gameplay Configs
//**************************
var array<HEPlayer>			Players;
var int						PlayerNumber;
	 
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
	local HEPlayer empt;
	`log("---[HE::PreBeginPlay]PreBeginPlay Called.");
	
	CreateEmptyHEP(empt);
	Players.AddItem(empt); //Add one empty instance into array to fit index
	
	`log("---[HE::PreBeginPlay]Add ept ins into Players array, current length(except ept ins) "$Players.Length-1);
	
	if(!bInitedConfig)
	{
		`log("---[HE::PreBeginPlay]Init Basic Mutator Values...");
		InitBasicMutatorValues();
		
		`log("---[HE::PreBeginPlay]Save to config...");
		SaveConfig();
	}
	
	UpdateHEConfig();
	
	super.PreBeginPlay();
}

//2.NotifyLogin, when player enters game
//	Add him into HEPlayer array to manage him
function NotifyLogin(Controller NewPlayer)
{
	`log("---[HE::NotifyLogin]Notify a new player logins in...");
	
	super.NotifyLogin(NewPlayer);
}

//3.PostBeginPlay, after game starts
function PostBeginPlay()
{	
	`log("---[HE::PostBeginPlay]PostBeginPlay Called.");
	
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
	`log("---[HE::ModifyPlayer]ModifyPlayer Called.");
	
	KFPH.HealthRegenRate=(1/fCurrentRegenRate);
	`log("---[HE::ModifyPlayer]HealthRegenRate Set to "$KFPH.HealthRegenRate);

	//Re-initialize Players Array, Check if he exists in the game
	ReInitPlayersArry(Other);
	
	//Add this player in to Players array if he's new in this game
	AddHimIntoPlayers(Other);
	
	//Testing Rep, should be commented in release ver
	//Spawn(class'HE_RepTest', Other.Owner);
		
	super.ModifyPlayer(Other);
}

//5.NotifyLogout, when player exits
//	Delete him out of HEPlayer array
function NotifyLogout(Controller Exiting)
{	
	local HEPlayer HEP;
	`log("---[HE::NotifyLogout]Function called.");
	
	if(!NotifyPlayerExits(KFPlayerController(Exiting)))
	{
		`log("---[HE]WARNING: Fatal Error - Failed To Delete Object In HEPlayer Array, Exiting PlayerName = "$KFPlayerController(Exiting).PlayerReplicationInfo.PlayerName);
		ForEach Players(HEP)
			`log("---[HE]DEBUG: Current Array Existing Players' Names = "$HEP.KFPC.PlayerReplicationInfo.PlayerName);
	}
		
	super.NotifyLogout(Exiting);
}

//Initialize basic config default values used in the mutator
//Author recommended values, plz do not edit
function InitBasicMutatorValues()
{
	//Muatator Version Info
	Editable_HEVI.ThisMutatorName="HE_Main";
	Editable_HEVI.AuthorNickname="ArHShRn";
	Editable_HEVI.AuthorSteamcommunityURL="http://steamcommunity.com/id/ArHShRn/";
	Editable_HEVI.Version="Release 1.1.1";
	Editable_HEVI.LastUpdate="Oct.11th 2017 08:55 PM";
	HEVI=Editable_HEVI;
	
	//Mutator Config Variable
	bInitedConfig=True;
	
	//Mutator Mechanism
	bGetDosh=True;
	bRecoverAmmo=False;
	bAllowOverClocking=True;
	bEnableAAR_Headshots=True;

	//Gameplay Settings
	BonusDosh=37; 
	AmmoRecoverAmout=1;
	fCurrentRegenRate=40.0;
	HealthHealingAmount=12; 
	ArmourHealingAmount=20;
	OverclockLimitHealth=175; 
	OverclockLimitArmour=200;
}

//Initialize basic config default values used in the mutator
//Used for dynamic settings
function InitBasicMutatorValuesByIns(HEConfig ins)
{
	local KFPawn_Human KFPH;
	//Mutator Config Variable
	bInitedConfig=True;
	
	//Mutator Mechanism
	bGetDosh=ins.bGetDosh;
	bRecoverAmmo=ins.bRecoverAmmo;
	bAllowOverClocking=ins.bAllowOverClocking;
	bEnableAAR_Headshots=ins.bEnableAAR_Headshots;

	//Gameplay Settings
	BonusDosh=ins.BonusDosh;
	AmmoRecoverAmout=ins.AmmoRecoverAmout;
	fCurrentRegenRate=ins.fCurrentRegenRate;
	HealthHealingAmount=ins.HealthHealingAmount;
	ArmourHealingAmount=ins.ArmourHealingAmount;
	OverclockLimitHealth=ins.OverclockLimitHealth;
	OverclockLimitArmour=ins.OverclockLimitArmour;
	
	ForEach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
		KFPH.HealthRegenRate=(1/fCurrentRegenRate);
}

//To add a new player into Players Array
//if player is died last wave, update his info to the array
function AddHimIntoPlayers(Pawn P)
{
	local HEPlayer				instance, HEP;
	local KFPlayerController	PlayerKFPC;
	local KFPawn_Human			PlayerKFPH;
	local int					PlayerIndex;


	PlayerKFPC=KFPlayerController(P.Controller);
	PlayerKFPH=KFPawn_Human(P);
	
	if(PlayerKFPC==None || PlayerKFPH==None) //if he's not Human, return
		return;
	
	//Check if he's already in game
	ForEach Players(HEP)
	{
		`log("---[HE::AddHimIntoPlayers]ForEach Players(HEP)");
		if(HEP.bIsEpt)
			continue;
			
		if(HEP.KFPC == PlayerKFPC)
			return;
	}
	
	//Here, he's a new player to game
	++PlayerNumber; // player number +1
	PlayerIndex=PlayerNumber; // Nth player's index is N because there's an empty instance in array[0];
	Players.AddItem(instance);
	`log("---[HE::AddHimIntoPlayers]Players array current length(except empty ins) "$Players.Length-1);
	
	Players[PlayerIndex].KFPC=PlayerKFPC;//Will not be invalid when he died last wave
	
	//Should be re-inited every time the ModifyPlayer is called(e.g, he died last wave)
	Players[PlayerIndex].KFPH=PlayerKFPH;//Will be invalid when he died last wave
	
	Players[PlayerIndex].LastPerk=PlayerKFPC.GetPerk().GetPerkClass();
	
	//Spawn Player's HUDManager and set his HUD
	//First spawn a manager and set owner to this Pawn's player
	Players[PlayerIndex].HUDManager = Spawn(class'HE_HUDManager', Players[PlayerIndex].KFPC);
	`log("---[HE]Spawned a new HUDManager="$Players[PlayerIndex].HUDManager.Name);
	Players[PlayerIndex].HUDManager.ClientSetHUD();
	
	//Spawn Trader Manager
	Players[PlayerIndex].TraderManager = Spawn(class'HE_TraderManager', Players[PlayerIndex].KFPC);
	`log("---[HE]Spawned a new HE_TraderManager="$Players[PlayerIndex].TraderManager.Name);
	Players[PlayerIndex].TraderManager.StartSyncItem();
	
	//Spawn Chat Controller
	Players[PlayerIndex].ChatController = Spawn(class'HE_ChatController', Players[PlayerIndex].KFPC);
	Players[PlayerIndex].ChatController.ClientGetTrigger();
	Players[PlayerIndex].ChatController.ClientSetHE_Main(HE_MainConfig);
	`log("---[HE]Spawned a new HE_ChatController="$Players[PlayerIndex].ChatController.Name);
	Players[PlayerIndex].ChatController.ClientPrint("If you see this, then this works fine.", True);
	
	//Set Delta and Recover Pool
	Players[PlayerIndex].HealthDelta=0.f;
	Players[PlayerIndex].ArmorDelta=0.f;
	Players[PlayerIndex].HealthToRecover=0.f;
	Players[PlayerIndex].ArmorToRecover=0.f;
	
	Players[PlayerIndex].Index=PlayerIndex;//Use PlayerIndex just to ensure he's added to the right position
	Players[PlayerIndex].HUDManager.ClientAddChatLine("Array Index="$PlayerIndex, "ffea00");
	Players[PlayerIndex].HUDManager.ClientAddChatLine("Current PlayerNumber="$PlayerNumber, "ffea00");
	`log("---[HE::AddHimIntoPlayers]Added him into array / INDEX="$PlayerIndex);
}

//Re-initialize Players Array
//Check if there's player left the game
function ReInitPlayersArry(Pawn P=None)
{
	local int						InGamePlayerIndex;
	local bool						bIsDiedLastWave;
	local KFPawn_Human				PlayerKFPH;
	local KFPlayerController    	PlayerKFPC;
	local HEPlayer					TargetHEP;

	InGamePlayerIndex=0;
	if( P == None )
		return;
		
	PlayerKFPH=KFPawn_Human(P);
	PlayerKFPC=KFPlayerController(P.Controller);
		
	//Check Players array to find him
	ForEach Players(TargetHEP)
	{
		`log("---[HE::ReInitPlayersArry]ForEach Players(TargetHEP)");
		if(TargetHEP.bIsEpt)
			continue;
			
		if(PlayerKFPC == TargetHEP.KFPC)
		{
			InGamePlayerIndex = TargetHEP.Index;
			bIsDiedLastWave = True;
			break;
		}
	}
		
	//If player died last wave, update Player Info
	//HUD, HUDManager, TraderManager, ChatController doesn't need respawning again
	if(bIsDiedLastWave)
	{		
		//Update his new KFPH into the array
		Players[InGamePlayerIndex].KFPH=PlayerKFPH;
		
		//Set its perk class
		Players[InGamePlayerIndex].LastPerk=PlayerKFPC.GetPerk().GetPerkClass();
		
		//Set Delta n Recover Pool
		Players[InGamePlayerIndex].HealthDelta=0.f;
		Players[InGamePlayerIndex].ArmorDelta=0.f;
		Players[InGamePlayerIndex].HealthToRecover=0.f;
		Players[InGamePlayerIndex].ArmorToRecover=0.f;
		
		Players[InGamePlayerIndex].HUDManager.ClientAddChatLine("YOU DIED LAST WAVE", "ff0000"); //Red
		Players[InGamePlayerIndex].HUDManager.ClientAddChatLine("KILLER:"$PlayerKFPC.PWRI.ClassKilledByLastWave.Name, "ff0000"); //Red
		`Log("---[HE::ReInitPlayersArry][HEPlayer_"$InGamePlayerIndex$"]"$" Respawned and Pawn updated");
	}
}

//Delete him from HEPlayer array and re-assign each instance's location
function bool NotifyPlayerExits(KFPlayerController KFPC)
{
	local HEPlayer TargetHEP;
	local int PIndex;
	local bool bIsFindAndRemoved;
	
	PIndex = -1;
	bIsFindAndRemoved = False;
	
	if(KFPC == None)
	{
		`log("---[HE::NotifyPlayerExits]WARNING: Ghost Detected!");
		return False;
	}
	
	//Find and remove him
	ForEach Players(TargetHEP)
	{
		if(TargetHEP.KFPC == KFPC)
		{
			`log("---[HE::NotifyPlayerExits]ACTION: Exited player KFPC find in Players Array. Current Length "$Players.Length-1);
			
			PIndex = TargetHEP.Index;
			Players.RemoveItem(Players[PIndex]);
			`log("---[HE::NotifyPlayerExits]ACTION: Exited player removed from Players Array. PIndex "$PIndex$", Current Length "$Players.Length-1);
			
			bIsFindAndRemoved = True;
			break;
		}
	}
	
	//If the P4 is removed, then the array is like this:
	//Index of array   :  0   1   2   3   4   5
	//Index in HEPlayer:  0   1   2   3   5   6
	//KFPC             :  N   P1  P2  P3  P5  P6
	//KFPH             :  N   PH1 PH2 PH3 PH5 PH6
	//
	//NOT LIKE THIS!!!!:
	//Index of array   :  0   1   2   3   4   5   6
	//Index in HEPlayer:  0   1   2   3   N   5   6
	//KFPC             :  N   P1  P2  P3  N   P5  P6
	//KFPH             :  N   PH1 PH2 PH3 N   PH5 PH6
	//Re-assign their index and PlayerNumber
	if(bIsFindAndRemoved)
	{
		--PlayerNumber;
		PIndex = 1;
		
		ForEach Players(TargetHEP)
		{
			if(TargetHEP.bIsEpt)
				continue;		
			
			if(TargetHEP.Index == PIndex)
			{
				TargetHEP.HUDManager.ClientAddChatLine("Maintains Original Index", "ff0000");
				`log("---[HE::NotifyPlayerExits]Index["$PIndex$"] maintains its original index");
			}
			else
			{
				TargetHEP.Index = PIndex;
				TargetHEP.HUDManager.ClientAddChatLine("Re-Assign New Index "$PIndex, "ff0000");
				`log("---[HE::NotifyPlayerExits]Array re-assigned at index["$PIndex$"] PlayerName= "$KFPC.PlayerReplicationInfo.PlayerName);
			}
			++PIndex;
		}
	}
	else
	{
		`log("---[HE::NotifyPlayerExits]WARNING: Failed to find and remove him!");
		return False;
	}
	
	return True;
	
}

//Create an empty HEPlayer object to init it
function CreateEmptyHEP(out HEPlayer tmp)
{
	tmp.pShotTarget=None;			
	tmp.LastTarget=None;			 
	tmp.KFWeap=None;
	tmp.KFPRI=None;
	tmp.KFPC=None;				 
	tmp.KFPM_Victim=None;			 
	tmp.KFPH=None;			 
	tmp.Index=-1;
	//tmp.ConfigNotify=-1;				 
	tmp.fLastHSC=0;
	tmp.bIsEpt=True;
}

//Update HEConfig structure
function UpdateHEConfig()
{
	//Init HEConfig Structure
	//Mutator Config Variable
	HE_MainConfig.bInitedConfig=True;
	//Mutator Mechanism
	HE_MainConfig.bGetDosh=bGetDosh;
	HE_MainConfig.bRecoverAmmo=bRecoverAmmo;
	HE_MainConfig.bAllowOverClocking=bAllowOverClocking;
	HE_MainConfig.bEnableAAR_Headshots=bEnableAAR_Headshots;
	//Gameplay Settings
	HE_MainConfig.BonusDosh=BonusDosh;
	HE_MainConfig.AmmoRecoverAmout=AmmoRecoverAmout;
	HE_MainConfig.fCurrentRegenRate=fCurrentRegenRate;
	HE_MainConfig.HealthHealingAmount=HealthHealingAmount;
	HE_MainConfig.ArmourHealingAmount=ArmourHealingAmount;
	HE_MainConfig.OverclockLimitHealth=OverclockLimitHealth;
	HE_MainConfig.OverclockLimitArmour=OverclockLimitArmour;
	HE_MainConfig.fCurrentRegenRate=fCurrentRegenRate;
	//Mutator Version
	HE_MainConfig.HEVI.ThisMutatorName="HE_Main";
	HE_MainConfig.HEVI.AuthorNickname="ArHShRn";
	HE_MainConfig.HEVI.AuthorSteamcommunityURL="http://steamcommunity.com/id/ArHShRn/";
	HE_MainConfig.HEVI.Version="Release 1.0.1";
	HE_MainConfig.HEVI.LastUpdate="Sept.15th 2017 07:31 AM";
}

//*************************************************
//*  Main Func
//*************************************************
//Headshot Recover Function
//Version 1.1.2
//-OC recover ammount will be added into recover pool
function HeadshotRecover(int i)
{
	if(bAllowOverClocking)
	{
		//Health
		if(Players[i].KFPC.Pawn.Health > Players[i].KFPC.Pawn.HealthMax) //OC
			Players[i].HealthToRecover += int(1.5 * HealthHealingAmount);
			//Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+int(1.5*HealthHealingAmount), OverclockLimitHealth);
		else //Normal
			Players[i].KFPC.Pawn.Health=Players[i].KFPC.Pawn.Health+HealthHealingAmount;
			
		//Armor
		if(Players[i].KFPH.Armor > Players[i].KFPH.MaxArmor) //OC
			Players[i].ArmorToRecover += int(1.5 * ArmourHealingAmount);
			//Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+int(1.5*ArmourHealingAmount), OverclockLimitArmour);
		else //Normal
			Players[i].KFPH.Armor=Players[i].KFPH.Armor+ArmourHealingAmount;
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
	
	//Chat Controller Checking Msg
	//Check wave activity
	Players[i].ChatController.NotifyWaveActivity(KFGameInfo(WorldInfo.Game).IsWaveActive());
	Players[i].ChatController.Recheck();
	
	//Server accepts config changes
	if(Players[i].ChatController.FullAccess
		&& Players[i].ChatController.ConfigChanged
		&& !KFGameInfo(WorldInfo.Game).IsWaveActive())
	{
		InitBasicMutatorValuesByIns(Players[i].ChatController.HE_MainConfig);
		UpdateHEConfig();
		Players[i].ChatController.ClientSetHE_Main(HE_MainConfig);
		Players[i].ChatController.ConfigChanged = False;
		Players[i].ChatController.ClientSay("Config Is Accepted");
	}
	
	//Version 1.1.2
	//Tick overclock armor and health Increment
	//Check recover pool and recover health and armor
	if(Players[i].KFPC.Pawn.Health > Players[i].KFPC.Pawn.HealthMax)//If he's in OC status
	{
		Players[i].HealthDelta += DeltaModifier * HealthHealingAmount * DeltaTime;
		if(Players[i].HealthDelta >= 1.f)
		{
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health++, OverclockLimitHealth);
			Players[i].HealthDelta -= 1.f;
		}
	}
	if(Players[i].KFPH.Armor > Players[i].KFPH.MaxArmor)//If he's in OC status
	{
		Players[i].ArmorDelta += DeltaModifier * ArmourHealingAmount * DeltaTime;
		if(Players[i].ArmorDelta >= 1.f)
		{
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor++, OverclockLimitArmour);
			Players[i].ArmorDelta -= 1.f;
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
	local int i;
	
	//ForEach Player in Players Array
	for(i=1; i<=PlayerNumber; ++i)
		TickMutRecover(i, DeltaTime);
		
	super.Tick(DeltaTime);
}

defaultproperties
{
	DeltaModifier=0.2f //Health and armor pool delta
	
	PlayerNumber=0
	bInNormalTime=True
}