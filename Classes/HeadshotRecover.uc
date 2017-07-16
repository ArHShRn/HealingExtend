//=============================================================================
// Healing Extend Mutator : Head Shot Recover
// This is the second mutator containing in HealingExtend Mut
// 
// This mutator provides you the possibility to recover Armour or Health 
//		while you just did a single head shot
//		
//		Attention:	You have to do a decap to get the effect !
//					The mutator is supposed to install on a server which is
//						having less than 16 players due to the structure and
//						the process, I'm working on a better way to do it
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//=============================================================================
//struct native PostWaveReplicationInfo
//{
//	var Vector 	VectData1; //used for compressing data //X:HeadShots Y:Dosh Earned Z:Damage Dealt
//	var Vector 	VectData2;	//used for compressing data //Damage Taken, Heals Received, Heals Given
//
//	var byte	LargeZedKills;
//	//Dialog
//	var bool 	bDiedDuringWave;
//	var bool	bBestTeammate;
//	var bool	bKilledMostZeds;
//	var bool	bEarnedMostDosh;
//	var bool	bAllSurvivedLastWave;
//	var bool	bSomeSurvivedLastWave;
//	var bool	bOneSurvivedLastWave;
//	var bool	bKilledFleshpoundLastWave;
//	var bool	bKilledScrakeLastWave;
//	/** Work-around so we don't have to wait for GRI.OpenTrader() to determine dialog */
//	var bool    bOpeningTrader;
//
//	var class< KFPawn_Monster > ClassKilledByLastWave;
//
//	var byte	RepCount;
//};
//=============================================================================

class HeadshotRecover extends KFMutator
	config(HealingExtend);

/* Every player in the game should have a Healing Extend structure
	to restore the info he has
*/
	struct HEPlayer
{
	var Pawn					pShotTarget;			//	A shot target pawn he owns, Use to avoidi checking ShotTarget frequently
	var Pawn					LastTarget;				//	His last zed target
	var KFPlayerController		KFPC;					//	His KFPlayerController class
	var KFPawn_Monster			KFPM_Victim;			//	Zed victim who damaged by him
	var KFPawn_Human			KFPH;					//	His KFPawn_Human
	
	var int						Index;					//  Shows his Index
	var int						HeadshotsInLogTime;		//  How many head shots are done by him in dLogTime
	var int						TotalHsThisWave;		//  How many head shots are done by him in this wave
	var int						TotalHsThisZedTime;		//  How many head shots are done bt him in zed time
};
	
	//System
var config int				dLogTime;				// Set how much time to log the headshot been done and health been healed
var config bool				bEnableProcessFreqcy;	// Set if it's enabled to limit healing frequency
var config float			fHealingFreq;			// Set how much time (seconds) to process each healing of health or armour
var config bool				bEnableHeadshotCount;	// Set if it's enabled to see how many head shots are done by him every dLogTime
//var config bool			bEnableHeadshotSort;	// Set if it's enabled to sort and detect him who shoots most headshoots in dLogTime
//var config bool			bEnableFirstScoreBonus;	// Set if it's enabled to add bonus health to him who shoots most headshoots in dLogTime
var config bool				bAllowOverClocking;		// Set if it's enabled to get beyond the max health or armor
var config bool				bInitedConfig;			// If you want to restore the default setting plz set this to False
var config bool				bRecoverAmmo;			// Set if it;s enabled to recover ammo if he does a decap
var config bool				bGetDosh;				// Set if it's enabled to get bonus dosh if he does a decap
var	bool					bClearZedTime;			// To check if it's ZedTime clear or not
var bool					bHLFlag;				// If it's true, then process healing function
var bool					bLogTHTW_Flag;			//A flag to check if it's time to log TotalHsThisWave

	//GamePlay
var array<HEPlayer>			Players;
var HEPlayer				EmptyInstance;
var int						PlayerNumber;			// How many players are in the game
var bool					bIsWaveEnded;
	 
	//Settings
var config int				HealthHealingAmount;	// How much health to heal when he does a headshot
var config int				ArmourHealingAmount;	// How much armour to heal when he does a headshot
var config int				AmmoRecoverAmout;		// How much ammo to recover when he does a headshot
var config int				BonusDosh;				// How much dosh to give when he does a headshot
var config int				HealingMode;			// 0 for both, 1 for health only, 2 for armour only
var config int				OverclockLimitHealth;	// The maximum health he can get in Overclocking mode
var config int				OverclockLimitArmour;	// The maximum armour he can get in Overclocking mode
//var config int			dFirstScoreBonus;		// Set bonus ammount

function InitMutator(string Options, out string ErrorMessage)
{
	if(!bInitedConfig)
	{
		InitBasicMutatorValues();
		SaveConfig();
	}
	super.InitMutator( Options, ErrorMessage );
}

function PostBeginPlay()
{	
	/*Init basic values which are not in config*/
	PlayerNumber=0;
	bIsWaveEnded=False;
	bHLFlag=False;
	bLogTHTW_Flag=True;
	//Add empty Instance into Players Array
	//In order to make array's Index equal to player's Index
	InitPlayersArry();


	//Healing Limit Freq
	if(bEnableProcessFreqcy)
		SetTimer(fHealingFreq, True, 'SetHLimitFlag');
	
	//Headshot counter
	if(bEnableHeadshotCount)
		SetTimer(dLogTime, True, 'LogHeadshots');
		
	//Logger
	//SetTimer(60, True, 'LogMutStat');
	//SetTimer(bHEZedArryClearDura, True, 'ClearDeadZeds');
	
	super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{	
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
	//System
	dLogTime=30;
	bEnableProcessFreqcy=True; 
	fHealingFreq=0.25; 
//	bEnableHeadshotMsg;
	bEnableHeadshotCount=False;
//	bEnableHeadshotSort;
//	bEnableFirstScoreBonus;
	bAllowOverClocking=False;
	bClearZedTime=True;
	bInitedConfig=True;
	bRecoverAmmo=True;
	bGetDosh=True;

	//Settings
	HealthHealingAmount=3; 
	ArmourHealingAmount=5;
	AmmoRecoverAmout=1; //Means he will not cost ammo if he did a decap
	BonusDosh=50; 
	HealingMode=0; 
	OverclockLimitHealth=175; 
	OverclockLimitArmour=200; 
//	dFirstScoreBonus; 
}

//Set Flag to limit healing frequency
function SetHLimitFlag()
{
	bHLFlag=True;
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

//Log headshots each player in dLogTime
function LogHeadshots()
{
	local int i;
	for(i=1; i<=PlayerNumber; ++i)
	{
		Players[i].KFPC.ServerSay("["$Players[i].HeadshotsInLogTime$"] Headshots");
		Players[i].HeadshotsInLogTime=0;
		`Log(
			"[ArHShRn Mutators]HeadshotRecover: HeadshotsInLogTime["
			$i
			$"] Reset"
			);
	}
}

//Mutator Stat Logger
function LogMutStat()
{
	`Log("[ArHShRn Mutators]HeadshotRecover: dLogTime="$dLogTime);
	`Log("[ArHShRn Mutators]HeadshotRecover: bEnableHeadshotCount="$bEnableHeadshotCount);
	`Log("[ArHShRn Mutators]HeadshotRecover: HealingMode="$HealingMode);
	`Log("[ArHShRn Mutators]HeadshotRecover: HealthHealingAmount="$HealthHealingAmount);
	`Log("[ArHShRn Mutators]HeadshotRecover: ArmourHealingAmount="$ArmourHealingAmount);
	//`Log("[ArHShRn Mutators]HeadshotRecover: bEnableFirstScoreBonus="$bEnableFirstScoreBonus);
	//`Log("[ArHShRn Mutators]HeadshotRecover: dFirstScoreBonus="$dFirstScoreBonus);
}

//Re-initialize Players Array
//Check if there's player left the game
function ReInitPlayersArry(Pawn P=None)
{
	//local int						i;
	local int						InGamePlayerIndex;
	local KFPawn_Human				PlayerKFPH;
	//local KFPawn_Human				KFPH;
	//local array<KFPawn_Human>		ArrayKFPH;
	//local KFPlayerController		KFPC;
	local KFPlayerController    	PlayerKFPC;
	PlayerKFPH=KFPawn_Human(P);
	PlayerKFPC=KFPlayerController(P.Controller);
	
	////1.Add all KFPH in the world to ArrayKFPH
	//ForEach WorldInfo.AllPawns(class'KFPawn_Human', KFPH)
		//ArrayKFPH.AddItem(KFPH);
		
	//2.Update Player number each player restarted
	//PlayerNumber=ArrayKFPH.Length;
	
	//When the function is called without Pawn, just do 1.2. stuffs
	if(P!=None)
	{
		//3.If player died last wave, update Player Info (Like KFPH)
		if(isAlreadyInGame(P, InGamePlayerIndex)) //If his KFPC is already in game (like he died last wave)
		{
			//Update his new KFPH into the array, to avoid failing
			Players[InGamePlayerIndex].KFPH=PlayerKFPH;
			`Log("["$InGamePlayerIndex$"]"$" Respawned and Pawn updated");
			PlayerKFPC.ServerSay
				(
				"No."
				$InGamePlayerIndex
				$" Player Respawned "
				);
		}
		
		////4.Check if there's a player left game
		//for(i=1;i<Players.Length;++i)
		//{
			////If there is, remove it
			//if(ArrayKFPH.Find(,Players[i].KFPH)==-1)
			//{
				//Players.RemoveItem(Players[i]);
				//`Log("[ArHShRn Mutators]HeadshotRecover: Removed A Left Player");
			//}
		//}
	
		////5.Re-assign players' index
		//ForEach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		//{
			////ForEach HEPlayer in Players Array
			//for(i=1;i<Players.Length;++i)
			//{
				////if find him in Players Array
				//if(KFPC==Players[i].KFPC)
				//{
					//Players[i].Index=i;
					//`Log("[ArHShRn Mutators]HeadshotRecover:"$Players[i].KFPC.PlayerReplicationInfo.PlayerName$"Re-Assigned Index With ["$i$"]");
					//break;
				//}
			//}
		//}
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
	//local int					LastTotalKill;

	PlayerKFPC=KFPlayerController(P.Controller);
	PlayerKFPH=KFPawn_Human(P);
	if(PlayerKFPC==None || PlayerKFPH==None) //if he's not Human, return
		return;
	
	if(isAlreadyInGame(P, InGamePlayerIndex)) //If his KFPC is already in game (like he died last wave)
		return;
	
	//If he's a new player to game
	++PlayerNumber; // player number +1
	PlayerIndex=PlayerNumber; // Nth player's index is N because there's an empty instance in array[0];
	
	instance.KFPC=PlayerKFPC;
	instance.KFPH=PlayerKFPH;
	Players.AddItem(instance);

	Players[PlayerIndex].Index=PlayerIndex;
	Players[PlayerIndex].KFPC.ServerSay
		(
			"The No."$PlayerIndex
			$" Player"$Players[PlayerIndex].KFPC.PlayerReplicationInfo.PlayerName
			$" Joins Game!"
		);
}

//Initialize Players Array, add a Null instance into it
function InitPlayersArry()
{
	EmptyInstance.KFPC=None;
	EmptyInstance.LastTarget=None;
	EmptyInstance.KFPM_Victim=None;
	EmptyInstance.pShotTarget=None;
	EmptyInstance.KFPH=None;
	EmptyInstance.Index=0;
	EmptyInstance.HeadshotsInLogTime=0;
	EmptyInstance.TotalHsThisWave=0;
	//EmptyInstance.TotalHsThisRound=0;
	EmptyInstance.TotalHsThisZedTime=0;
	Players.AddItem(EmptyInstance);
}

//Return true if this Pawn is his LastTarget
simulated function bool isSameTarget(int PlayerIndex, Pawn P)
{
	return P==Players[PlayerIndex].LastTarget;
}

//Log Total Headshots This Wave
function TotalHSTW()
{
	local int i;
	for(i=1; i<=Players.Length; ++i)
	{
		Players[i].KFPC.ServerSay
		(
			"["
			$Players[i].TotalHsThisWave
			$"]Headshots Done"
		);
		Players[i].TotalHsThisWave=0;
	}
}

Event Tick(float DeltaTime)
{
	local int					i;
	local KFWeapon				KFWeap;
	//local KFPerk				KFP;
	
	//If wave is ended
	if(!MyKFGI.IsWaveActive())
	{
		if(bLogTHTW_Flag)
		{
			SetTimer(1, false, 'TotalHSTW');
			ReInitPlayersArry();
		}
		bLogTHTW_Flag=False;
		return;
	}
	bLogTHTW_Flag=True;
	
	//ForEach Player in Players Array
	for(i=1; i<=PlayerNumber; ++i)
	{
		//Set his pShotTarget to his ShotTarget
		Players[i].pShotTarget=Players[i].KFPC.ShotTarget;
		
		//If he's not shooting a target, continue to check next player
		if(Players[i].pShotTarget==None)
			continue;
		
		//If his ShotTarget is not the LastTarget
		if(!isSameTarget(i, Players[i].pShotTarget))
			//Set his LastTarget to ShotTarget
			Players[i].LastTarget=Players[i].pShotTarget; 
			
		//KFPawn_Monster victim he owns is his monster shooting target
		Players[i].KFPM_Victim=KFPawn_Monster(Players[i].pShotTarget);
		
		//If he's not shooting a monster (like shooting a KFHealing_Dart to teammates)
		//Continue to check next player
		if(Players[i].KFPM_Victim==None)
			continue;
		
		//If his KFPM_Victim's head health <=0, which means its head is been shot and dismembered
		if(Players[i].KFPM_Victim.HitZones[HZI_HEAD].GoreHealth<=0 && bHLFlag)
		{
			
			//	A simulated function can't exec so I put it here for a short time
			/* Main Function */
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
			
			//Recover ammo if takes a decap
			if(bRecoverAmmo)
			{
				KFWeap=KFWeapon(Players[i].KFPC.Pawn.Weapon);
				if(KFWeap!=None)
				{
					KFWeap.AmmoCount[KFWeap.GetAmmoType(KFWeap.CurrentFireMode)]=Min
					(
						KFWeap.AmmoCount[KFWeap.GetAmmoType(KFWeap.CurrentFireMode)]+AmmoRecoverAmout,
						KFWeap.MagazineCapacity[KFWeap.GetAmmoType(KFWeap.CurrentFireMode)]
					);
				}
			}
			//if(bGetDosh)
			//{
				//
			//}
			
			//Add one shot in his HeadshotsInLogTime and TotalHsThisWave
			++Players[i].HeadshotsInLogTime;
			++Players[i].TotalHsThisWave;
			
			/* Record how many headshots are done by him in Zed Time */
			bClearZedTime=True;
			if(`IsInZedTime(self))
			{
				bClearZedTime=False;
				++Players[i].TotalHsThisZedTime;
				Players[i].KFPC.ServerSay(Players[i].TotalHsThisZedTime$" Combo in ZedTime!");
			}
			if(bClearZedTime)
			{
				Players[i].TotalHsThisZedTime=0;
			}
			
			
			/* Clear flags */
			Players[i].pShotTarget=None;
			Players[i].KFPC.ShotTarget=None;	//Last Zed is killed, avoiding continiously healing
			bHLFlag=False;	//Disable healing process
		}
	}
	super.Tick(DeltaTime);
}

defaultproperties
{
}
