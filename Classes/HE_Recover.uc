//=============================================================================
// Healing Extend Mutator : Head Shot Recover
// This is the second mutator containing in HealingExtend Mut
// 
// This mutator provides you the possibility to recover Armour or Health 
//		while you just did a single head shot
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
// Version 0.1.3
// Last Update Date Aug.5th 2017
//=============================================================================
class HE_Recover extends KFMutator
	DependsOn(HE_DataStructure)
	config(HealingExtend);

//**************************
//*  System Configs
//**************************
var config bool				bUseHE_HUD;
var config float			fHealingFreq;			// Set how much time (seconds) to process each healing of health or armour
var config bool				bAllowOverClocking;		// Set if it's enabled to get beyond the max health or armor
var config bool				bInitedConfig;			// If you want to restore the default setting plz set this to False
var config bool				bRecoverAmmo;			// Set if it;s enabled to recover ammo if he does a decap
var config bool				bEnableAAR_Headshots;
var config bool				bGetDosh;				// Set if it's enabled to get bonus dosh if he does a decap
var	bool					bClearZedTime;			// To check if it's ZedTime clear or not
var bool					bHLFlag;				// If it's true, then process healing function
var bool					bLogTHTW_Flag;			//A flag to check if it's time to log TotalHsThisWave
var float					fLastHSC;

//**************************
//*  Gameplay Configs
//**************************
var class<HUD>				HE_HUDType;
var array<HEPlayer>			Players;
var int						PlayerNumber;			// How many players are in the game
var bool					bIsWaveEnded;
	 
//**************************
//*  Common Settings
//**************************
var config int				HealthHealingAmount;	// How much health to heal when he does a headshot
var config int				ArmourHealingAmount;	// How much armour to heal when he does a headshot
var config int				AmmoRecoverAmout;		// How much ammo to recover when he does a headshot
var config int				BonusDosh;				// How much dosh to give when he does a headshot
var config int				HealingMode;			// 0 for both, 1 for health only, 2 for armour only
var config int				OverclockLimitHealth;	// The maximum health he can get in Overclocking mode
var config int				OverclockLimitArmour;	// The maximum armour he can get in Overclocking mode

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
	tmp.PlayerHUD=None;
	tmp.Index=0;				 
	tmp.fLastHSC=0;
}

//*************************************************
//*  Initialization
//*************************************************
function InitMutator(string Options, out string ErrorMessage)
{
	if(!bInitedConfig)
	{
		`log("[HE_Recover]Init Basic Mutator Values...");
		InitBasicMutatorValues();
		
		`log("[HE_Recover]Save to config...");
		SaveConfig();
	}
	super.InitMutator( Options, ErrorMessage );
}

function PostBeginPlay()
{	
	local HEPlayer empt;
	CreateEmptyHEP(empt);
	Players.AddItem(empt);
	SetTimer(fHealingFreq, True, 'SetHLimitFlag');
	
	super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{	
	local KFPlayerController KFPC;
	KFPC=KFPlayerController(Other.Controller);
	
	//1.Re-initialize Players Array, Check if he exists in the game
	ReInitPlayersArry(Other);
	
	//2.Add this player in to Players array if he's new in this game
	AddHimIntoPlayers(Other);
	
	//3.Create his HUD on Server side if it's a server && also Standalone
	if(bUseHE_HUD)
	{
		KFPC.ClientSetHUD(HE_HUDType);
		//If it's standalone SOLO game, then we need to manually create a GFxMovieHUD
		if(WorldInfo.NetMode == NM_Standalone)
		{
			if(HE_HUD(KFPC.myHUD)==None)
			{
				`log("[HER:Standalone]Error spawning a new HE_HUD hud!");
				super.ModifyPlayer(Other);
			}
			`log("[HER:Standalone]Spawned a new HUD "$HE_HUD(KFPC.myHUD)$" for "$KFPC.PlayerReplicationInfo.PlayerName);
			//Create MovieHUD
			`log("[HER:Standalone]Creating New MovieHUD...");
			HE_HUD(KFPC.myHUD).CreateHUDMovie( False );
			`log("[HER:Standalone]Setting New GFxHUD...");
			KFPC.SetGFxHUD(HE_HUD(KFPC.myHUD).HudMovie);
		}		
	}
	
	`log("[HER:"$WorldInfo.NetMode$"]End ModifyPlayer function.");	
	super.ModifyPlayer(Other);
}

//Initialize basic config default values used in the mutator
//Author recommended values, plz do not edit
function InitBasicMutatorValues()
{
	//System
	bUseHE_HUD=True;
	fHealingFreq=0.25; 
	bAllowOverClocking=True;
	bClearZedTime=True;
	bInitedConfig=True;
	bRecoverAmmo=True;
	bEnableAAR_Headshots=True;
	bGetDosh=False;

	//Settings
	HealthHealingAmount=3; 
	ArmourHealingAmount=5;
	AmmoRecoverAmout=1;
	BonusDosh=50; 
	HealingMode=0; 
	OverclockLimitHealth=175; 
	OverclockLimitArmour=200; 
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
			`Log("[HE_Recover]["$InGamePlayerIndex$"]"$" Respawned and Pawn updated");
			PlayerKFPC.ServerSay("I Respawned ;)");
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
	Players.AddItem(instance);
	Players[PlayerIndex].Index=PlayerIndex;
	`log("[HE_Recover]Add him into array and INDEX="$PlayerIndex);
	Players[PlayerIndex].KFPC.ServerSay(Players[PlayerIndex].KFPC.PlayerReplicationInfo.PlayerName$" Joins Game!");
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
function HeadshotRecover(int i)
{
	//0 for both
	if(HealingMode==0)
	{	
		if(bAllowOverClocking)
		{
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+HealthHealingAmount, OverclockLimitHealth);
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+ArmourHealingAmount, OverclockLimitArmour);
		}
		else
		{
			Players[i].KFPC.Pawn.Health=Min
			(
			Players[i].KFPC.Pawn.Health+HealthHealingAmount, 
			Players[i].KFPC.Pawn.HealthMax
			);
	
			//need to know max armor ammount
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+ArmourHealingAmount, 175);
		}
	}
	//1 for health only
	if(HealingMode==1)
	{
		if(bAllowOverClocking)
		{
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+HealthHealingAmount, OverclockLimitHealth);
		}
		else
		{
			Players[i].KFPC.Pawn.Health=Min
			(
			Players[i].KFPC.Pawn.Health+HealthHealingAmount, 
			Players[i].KFPC.Pawn.HealthMax
			);
		}
	}
	//2 for armor only
	if(HealingMode==2)
	{
		if(bAllowOverClocking)
		{
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+ArmourHealingAmount, OverclockLimitArmour);
		}
		else
		{
			//need to know max armor ammount
			Players[i].KFPH.Armor=Min(Players[i].KFPH.Armor+ArmourHealingAmount, 175);
		}
	}
}

function AddPlayerDosh(int i)
{
	KFPlayerReplicationInfo(Players[i].KFPC.PlayerReplicationInfo).AddDosh(BonusDosh);
}

function TickMutRecover(int i)
{
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
Event Tick(float DeltaTime)
{
	local int i;
	
	bIsWaveEnded=!MyKFGI.IsWaveActive();
	
	//If wave is ended
	if(bIsWaveEnded)
	{
		//Re-Init Players Array
		ReInitPlayersArry();
		bIsWaveEnded=False;
		return;
	}
	
	//ForEach Player in Players Array
	for(i=1; i<=PlayerNumber; ++i)
		TickMutRecover(i);
		
	super.Tick(DeltaTime);
}

defaultproperties
{
	PlayerNumber=0
	bIsWaveEnded=False
	bHLFlag=False
	bLogTHTW_Flag=True
	HE_HUDType=class'HealingExtend.HE_HUD'
}