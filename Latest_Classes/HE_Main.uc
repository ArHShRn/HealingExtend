//=============================================================================
// Healing Extend Mutator Main Part
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
// Version Release 1.0.1
// -Combine Healing n' Headshot Recovery
//
// Last Update Date Aug.31th 2017
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

//System Variable Configs
var config float			fCurrentRegenRate;
var config float			fHealingFreq;
var config bool				bAllowOverClocking;	
var config bool				bInitedConfig;
var config bool				bRecoverAmmo;	
var config bool				bEnableAAR_Headshots;
var config bool				bGetDosh;

//System Variables
var HE_ChatController		ChatController;				
var	bool					bClearZedTime;			
var bool					bHLFlag;			
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

//**************************
//*  Create an empty HEPlayer object to init it
//**************************
function CreateEmptyHEP(out HEPlayer tmp)
{
	tmp.pShotTarget=None;			
	tmp.LastTarget=None;			 
	tmp.KFWeap=None;
	tmp.KFPRI=None;
	tmp.KFPC=None;				 
	tmp.KFPM_Victim=None;			 
	tmp.KFPH=None;				 
	tmp.Index=0;				 
	tmp.fLastHSC=0;
}

//*************************************************
//*  Initialization
//*************************************************
function PreBeginPlay()
{
	//Spawn Chat Controller
	if(ChatController != None)
		ChatController.Destroy();
	ChatController = Spawn(class'HE_ChatController');
	`log("[HE:"$WorldInfo.NetMode$"]ChatController Spawned.");
	super.PreBeginPlay();
}

function PostBeginPlay()
{	
	local HEPlayer empt;
	
	CreateEmptyHEP(empt);
	Players.AddItem(empt);
	
	if(!bInitedConfig)
	{
		`log("[HE:"$WorldInfo.NetMode$"]Init Basic Mutator Values...");
		InitBasicMutatorValues();
		
		`log("[HE:"$WorldInfo.NetMode$"]Save to config...");
		SaveConfig();
	}
	
	//Set ChatController's HE_Main Config
	ChatController.HE_MainConfig = self;
	`log("[HE:"$WorldInfo.NetMode$"]ChatController HE_MainConfig sets to "$ChatController.HE_MainConfig);
	ChatController.ClientSetHE_Main(self);
	`log("[HE:"$WorldInfo.NetMode$"]ChatController Client HE_MainConfig is set");
	
	SetTimer(fHealingFreq, True, 'SetHLimitFlag');
	
	super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{	
	//Instant Healing Stuffs
	local KFPawn_Human KFPH;
	KFPH=KFPawn_Human(Other);
	KFPH.HealthRegenRate=(1/fCurrentRegenRate);
	`log("[HER:"$WorldInfo.NetMode$"]HealthRegenRate Set to "$KFPH.HealthRegenRate);

	//1.Re-initialize Players Array, Check if he exists in the game
	ReInitPlayersArry(Other);
	
	//2.Add this player in to Players array if he's new in this game
	AddHimIntoPlayers(Other);
	
	//Testing Rep, should be commented in release ver
	//Spawn(class'HE_RepTest', Other.Owner);
	
	//3.Get Trigger
	ChatController.ClientGetTrigger();
	ChatController.ClientSay("--Thanks For Subscribing--");
	ChatController.ClientPrint("--HE ChatController Succesfully Initialized--");
	ChatController.ClientPrint("--Thanks For Sybscribing--");
		
	super.ModifyPlayer(Other);
}

//Initialize basic config default values used in the mutator
//Author recommended values, plz do not edit
function InitBasicMutatorValues()
{
	//Muatator Version Info
	Editable_HEVI.ThisMutatorName="HE_Main";
	Editable_HEVI.AuthorNickname="ArHShRn";
	Editable_HEVI.AuthorSteamcommunityURL="http://steamcommunity.com/id/ArHShRn/";
	Editable_HEVI.Version="Release 1.0.1";
	Editable_HEVI.LastUpdate="Sept.15th 2017 07:31 AM";
	HEVI=Editable_HEVI;
	
	//Mutator Config Variable
	bInitedConfig=True;
	
	//Mutator Mechanism
	bGetDosh=False;
	fHealingFreq=0.25;
	bRecoverAmmo=False;
	bAllowOverClocking=True;
	bEnableAAR_Headshots=True;

	//Gameplay Settings
	BonusDosh=50; 
	AmmoRecoverAmout=1;
	fCurrentRegenRate=40.0;
	HealthHealingAmount=12; 
	ArmourHealingAmount=20;
	OverclockLimitHealth=175; 
	OverclockLimitArmour=200;
}

//Initialize basic config default values used in the mutator
//Used for dynamic settings
function InitBasicMutatorValuesByIns(HE_Main ins)
{
	local KFPawn_Human KFPH;
	//Mutator Config Variable
	bInitedConfig=True;
	
	//Mutator Mechanism
	bGetDosh=ins.bGetDosh;
	fHealingFreq=ins.fHealingFreq;
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

//Return true if player is already in game
//Use to detect if player is died last wave
function bool isAlreadyInGame(Pawn P, optional out int Index)
{
	local int							i;
	local KFPlayerController			KFPC;
	KFPC = KFPlayerController(P.controller);
	
	for(i=0;i<Players.Length;++i)
	{
		if(Players[i].KFPC==KFPC)
		{
			Index=i;
			return true;
		}
	}
	return false;
}

//Re-initialize Players Array
//Check if there's player left the game
function ReInitPlayersArry(Pawn P=None)
{
	local int						InGamePlayerIndex;
	local KFPawn_Human				PlayerKFPH;
	local KFPlayerController    	PlayerKFPC;

	if(P!=None)
	{
		PlayerKFPH=KFPawn_Human(P);
		PlayerKFPC=KFPlayerController(P.Controller);
		//If player died last wave, update Player Info
		if(isAlreadyInGame(P, InGamePlayerIndex))
		{
			//Update his new KFPH into the array
			Players[InGamePlayerIndex].KFPH=PlayerKFPH;
			//Update his health and armor for decrement
			Players[InGamePlayerIndex].HealthDecrement=float(Players[InGamePlayerIndex].KFPC.Pawn.Health);
			Players[InGamePlayerIndex].ArmorDecrement=float(Players[InGamePlayerIndex].KFPH.Armor);
			
			//Set its perk class
			Players[InGamePlayerIndex].LastPerk=PlayerKFPC.GetPerk().GetPerkClass();
			
			//Set his new HUD
			`log("[HER:"$WorldInfo.NetMode$"]Spawning a new HUDManager...");
			Players[InGamePlayerIndex].HUDManager = Spawn(class'HE_HUDManager', PlayerKFPC);
			`log("[HER:"$WorldInfo.NetMode$"]Spawned a new HUDManager="$Players[InGamePlayerIndex].HUDManager.Name);
			Players[InGamePlayerIndex].HUDManager.ClientSetHUD();
			`Log("[HE_Recover]["$InGamePlayerIndex$"]"$" Respawned and Pawn updated");
		}
	}
}

//To add a new player into Players Array
//if player is died last wave, update his info to the array
function AddHimIntoPlayers(Pawn P)
{
	local HEPlayer				instance;
	local KFPlayerController	PlayerKFPC;
	local KFPawn_Human			PlayerKFPH;
	local int					PlayerIndex;
	local int					InGamePlayerIndex;

	PlayerKFPC=KFPlayerController(P.Controller);
	PlayerKFPH=KFPawn_Human(P);
	if(PlayerKFPC==None || PlayerKFPH==None) //if he's not Human, return
		return;
	
	if(isAlreadyInGame(P, InGamePlayerIndex)) //If his KFPC is already in game (like he died last wave)
		return;
	
	//Here, he's a new player to game
	++PlayerNumber; // player number +1
	PlayerIndex=PlayerNumber; // Nth player's index is N because there's an empty instance in array[0];
	
	instance.KFPC=PlayerKFPC;
	instance.KFPH=PlayerKFPH;
	instance.LastPerk=PlayerKFPC.GetPerk().GetPerkClass();
	instance.HealthDecrement=float(PlayerKFPC.Pawn.Health);
	instance.ArmorDecrement=float(PlayerKFPH.Armor);
	
	//Set Player's HUD
	//First spawn a manager and set owner to this Pawn's player
	`log("[HER:"$WorldInfo.NetMode$"]Spawning a new HUDManager...");
	instance.HUDManager = Spawn(class'HE_HUDManager', PlayerKFPC);
	`log("[HER:"$WorldInfo.NetMode$"]Spawned a new HUDManager="$instance.HUDManager.Name);
	instance.HUDManager.ClientSetHUD();
	
	//Spawn Trader Manager
	instance.TraderManager = Spawn(class'HE_TraderManager', PlayerKFPC);
	`log("[HER:"$WorldInfo.NetMode$"]Spawned a new HE_TraderManager="$instance.TraderManager.Name);
	instance.TraderManager.StartSyncItem();

	
	`log("[HER:"$WorldInfo.NetMode$"]End ModifyPlayer function.");
	Players.AddItem(instance);
	Players[PlayerIndex].Index=PlayerIndex;
	`log("[HE_Recover]Add him into array and INDEX="$PlayerIndex);
}

//*************************************************
//*  Misc
//*************************************************
//Return true if this Pawn is his LastTarget
function bool isSameTarget(int PlayerIndex, Pawn P)
{
	return P==Players[PlayerIndex].LastTarget;
}

//Set Flag to limit healing frequency
function SetHLimitFlag()
{
	bHLFlag=True;
}

//*************************************************
//*  Main Func
//*************************************************
//Headshot Recover Function
function HeadshotRecover(int i)
{
	if(bAllowOverClocking)
	{
		//Health
		if(Players[i].KFPC.Pawn.Health > Players[i].KFPC.Pawn.HealthMax)
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+3*HealthHealingAmount, OverclockLimitHealth);
		else
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+HealthHealingAmount, OverclockLimitHealth);
		//Armor
		if(Players[i].KFPH.Armor > Players[i].KFPH.MaxArmor)
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+5*ArmourHealingAmount, OverclockLimitArmour);
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
	//Need to update Decrement every recovery
	Players[i].HealthDecrement=Players[i].KFPC.Pawn.Health;
	Players[i].ArmorDecrement=Players[i].KFPH.Armor;
}

//Add player dosh function
function AddPlayerDosh(int i)
{
	KFPlayerReplicationInfo(Players[i].KFPC.PlayerReplicationInfo).AddDosh(BonusDosh);
}

//Tick Mutator
function TickMutRecover(int i, float DeltaTime)
{	
	//Tick overclock armor and health Decrement
	
	//Set his pShotTarget to his ShotTarget
	Players[i].pShotTarget=Players[i].KFPC.ShotTarget;
		
	//If he's not shooting a target, continue to check next player
	if(Players[i].pShotTarget==None)
		return;
		
	//If his ShotTarget is not the LastTarget
	if(!isSameTarget(i, Players[i].pShotTarget))
		//Set his LastTarget to ShotTarget
		Players[i].LastTarget=Players[i].pShotTarget; 
		
	//KFPawn_Monster victim he owns is his monster shooting target
	Players[i].KFPM_Victim=KFPawn_Monster(Players[i].pShotTarget);
	
	//If he's not shooting a monster (like shooting a KFHealing_Dart to teammates)
	//Continue to check next player
	if(Players[i].KFPM_Victim==None)
		return;
	
	//If his KFPM_Victim's head health <=0, which means its head is been shot and dismembered
	if(Players[i].KFPM_Victim.HitZones[HZI_HEAD].GoreHealth<=0)
	{
		if(bHLFlag)
		{		
			//Add Dosh
			if(bGetDosh)
				AddPlayerDosh(i);
				
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
	
	/* Record in Zed Time */
	bClearZedTime=True;
	if(`IsInZedTime(self))
	{
		bClearZedTime=False;
		//Functions called in ZedTime
	}
	if(bClearZedTime)
	{
		//Functions called in NormalTime
	}
	
	/* Clear flags */
	Players[i].pShotTarget=None;
	Players[i].KFPC.ShotTarget=None;	//Last Zed is killed
	bHLFlag=False;	//Disable healing process
}

//*************************************************
//*  Tick Time Update
//*************************************************
//Tick event
Event Tick(float DeltaTime)
{
	local int i;
	
	//Tick check console command and Dynamic Update each wave end
	if(ChatController != None)
	{
		ChatController.Recheck();
		DynamicUpdate();
	}
	
	
	//ForEach Player in Players Array
	for(i=1; i<=PlayerNumber; ++i)
	{		
		TickMutRecover(i, DeltaTime);
		//OverclockDecrement(DeltaTime, Players[i]);
	}
		
	super.Tick(DeltaTime);
}

Event DynamicUpdate()
{
	//If this wave is end
	if(!KFGameInfo(WorldInfo.Game).IsWaveActive())
	{
		InitBasicMutatorValuesByIns(ChatController.HE_MainConfig);
		SaveConfig();
		//ChatController.ClientSay(">Server Has Accepted The Change<");
	}
}

////Player's overclocked health and armor decrement
//function OverclockDecrement(float DeltaTime, HEPlayer OnePlayer)
//{
	////If there's no OnePlayer then return
	//if(None == OnePlayer.KFPH)
		//return;
	//
	////Check health and armor state
	//if(OnePlayer.KFPC.Pawn.Health > OnePlayer.KFPC.Pawn.HealthMax)
	//{
		//OnePlayer.HealthDecrement=Max(float(OnePlayer.KFPC.Pawn.HealthMax), OnePlayer.HealthDecrement-DeltaTime * 3);
		//OnePlayer.KFPC.Pawn.Health=int(OnePlayer.HealthDecrement);
	//}
	//
	//if(OnePlayer.KFPH.Armor > OnePlayer.KFPH.MaxArmor)
	//{
		//OnePlayer.ArmorDecrement=Max(float(OnePlayer.KFPH.MaxArmor), OnePlayer.ArmorDecrement-DeltaTime * 5);
		//OnePlayer.KFPH.Armor=int(OnePlayer.ArmorDecrement);
	//}
//}


defaultproperties
{
	PlayerNumber=0
	bHLFlag=False
}