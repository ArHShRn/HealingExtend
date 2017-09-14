//=============================================================================
// Healing Extend Mutator Main Part No HUD
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
// Version Release 1.0.1
// -Combine Healing n' Headshot Recovery
// -This mut has no hud and it's a standard version
//
// Last Update Date Aug.31th 2017
//=============================================================================
class HE_Main_NoHUD extends KFMutator
	DependsOn(HE_DataStructure)
	config(HE_Main);

//**************************
//*  System Configs
//**************************
//Mutator Version Info
var config HEVersionInfo HEVI;
var HEVersionInfo Editable_HEVI;

//System Variable Configs
var config float			fCurrentRegenRate;
var config float			fHealingFreq;
var config bool				bAllowOverClocking;	
var config bool				bInitedConfig;
var config bool				bRecoverAmmo;	
var config bool				bEnableAAR_Headshots;
var config bool				bGetDosh;

//System Variables				
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
var config int				HealingMode;
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
		
	super.ModifyPlayer(Other);
}

//Initialize basic config default values used in the mutator
//Author recommended values, plz do not edit
function InitBasicMutatorValues()
{
	//Muatator Version Info
	Editable_HEVI.ThisMutatorName="HE_Main_NoHUD";
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
	HealingMode=0;
	AmmoRecoverAmout=1;
	fCurrentRegenRate=40.0;
	HealthHealingAmount=3; 
	ArmourHealingAmount=5;
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
			
			//Set its perk class
			Players[InGamePlayerIndex].LastPerk=PlayerKFPC.GetPerk().GetPerkClass();
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
function HeadshotRecover(int i)
{
	//0 for both
	if(HealingMode==0)
	{	
		if(bAllowOverClocking)
		{
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+HealthHealingAmount, Min(OverclockLimitHealth, 200));
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
			Players[i].KFPC.Pawn.Health=Min(Players[i].KFPC.Pawn.Health+HealthHealingAmount, Min(OverclockLimitHealth, 200));
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
	
	//ForEach Player in Players Array
	for(i=1; i<=PlayerNumber; ++i)
	{		
		TickMutRecover(i);
	}
		
	super.Tick(DeltaTime);
}

defaultproperties
{
	PlayerNumber=0
	bHLFlag=False
}