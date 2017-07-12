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

class HeadshotRecover extends Mutator
	config(HealingExtend);

/* Every player in the game should have a Healing Extend structure
	to restore the info he has
*/
	struct HEPlayer
{
	var KFPlayerController		KFPC;					//	His KFPlayerController class
	var Pawn					LastTarget;				//	His last zed target
	var KFPawn_Monster			KFPM_Victim;			//	Zed victim who damaged by him
	var Pawn					pShotTarget;			//	A shot target pawn he owns, Use to avoidi checking ShotTarget frequently
	var KFPawn_Human			KFPH;					//	His KFPawn_Human
	
	var int						HeadshotsInLogTime;		//  How many head shots are done by him in dLogTime
	var int						TotalHsThisWave;		//  How many head shots are done by him in this wave
	var int						TotalHsThisRound;		//  How many head shots are done by him in total wave
	var int						TotalHsThisZedTime;		//  How many head shots are done bt him in zed time
};

///* Every Zed in the game should have a Healing Extend structure
	//to restore the info he has
//*/
	//struct HEZed
//{
	//var KFPawn_Monster			Zed;
	//var bool					bIsThisZedDead;			// Check if this zed is dead
//};
	
	
	//System
var config int				dLogTime;				// Set how much time to log the headshot been done and health been healed
//var config bool			bEnableHeadshotMsg;		// Set if it's enabled to see a notification when he does a headshot
var config bool				bEnableHeadshotCount;	// Set if it's enabled to see how many head shots are done by him every dLogTime
//var config bool			bEnableHeadshotSort;	// Set if it's enabled to sort and detect him who shoots most headshoots in dLogTime
//var config bool			bEnableFirstScoreBonus;	// Set if it's enabled to add bonus health to him who shoots most headshoots in dLogTime
var config bool				bAllowOverClocking;		// Set if it's enabled to get beyond the max health or armor
//var config int			bHEZedArryClearDura;	// Set the time, how often does the DeadZeds array clear once
var	bool					bClearZedTime;			// To check if it's ZedTime clear or not

	
	//Debug
var config float			dDetectRadius;			// Set this to detect per head shot
var config bool				bIsEnableDebugSolo;		// Set if it's enabled to see what target he's aiming at in SOLO game
var config bool				bIsEnableDebugMsg;		// Set if it's enabled to see Debug Msg
//var config bool			bClearShotTarget;		// Set false to debug shot target

	//GamePlay
var array<HEPlayer>			Players;
//var array<HEZed>			DeadZeds;				//Zeds who are headshot by players and dead go into this Arry
													//should reset per bHEZedArryClearDura
var int						PlayerNumber;			// How many players are in the game
	 
	//Settings
var config int				HealthHealingAmount;	// How much health to heal when he does a headshot
var config int				ArmourHealingAmount;	// How much armour to heal when he does a headshot
var config int				HealingMode;			// 0 for both, 1 for health only, 2 for armour only
//var config int			dFirstScoreBonus;		// Set bonus ammount

	
function PostBeginPlay()
{
	SaveConfig();
	
	PlayerNumber=0;
	InitPlayersArry();
	
	if(bEnableHeadshotCount)
		SetTimer(dLogTime, True, 'LogHeadshots');
	SetTimer(60, True, 'LogMutStat');
	//SetTimer(bHEZedArryClearDura, True, 'ClearDeadZeds');
	super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{
	//Add this player in to Players array if he's new in this game
	AddHimIntoPlayers(Other);
	super.ModifyPlayer(Other);
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

function LogMutStat()
{
	`Log("[ArHShRn Mutators]HeadshotRecover: dLogTime="$dLogTime);
	`Log("[ArHShRn Mutators]HeadshotRecover: bEnableHeadshotCount="$bEnableHeadshotCount);
	`Log("[ArHShRn Mutators]HeadshotRecover: dDetectRadius="$dDetectRadius);
	`Log("[ArHShRn Mutators]HeadshotRecover: bIsEnableDebugSolo="$bIsEnableDebugSolo);
	`Log("[ArHShRn Mutators]HeadshotRecover: HealingMode="$HealingMode);
	`Log("[ArHShRn Mutators]HeadshotRecover: HealthHealingAmount="$HealthHealingAmount);
	`Log("[ArHShRn Mutators]HeadshotRecover: ArmourHealingAmount="$ArmourHealingAmount);
	`Log("[ArHShRn Mutators]HeadshotRecover: bIsEnableDebugMsg="$bIsEnableDebugMsg);
	//`Log("[ArHShRn Mutators]HeadshotRecover: bEnableHeadshotMsg="$bEnableHeadshotMsg);
	//`Log("[ArHShRn Mutators]HeadshotRecover: bEnableHeadshotSort="$bEnableHeadshotSort);
	//`Log("[ArHShRn Mutators]HeadshotRecover: bEnableFirstScoreBonus="$bEnableFirstScoreBonus);
	//`Log("[ArHShRn Mutators]HeadshotRecover: dFirstScoreBonus="$dFirstScoreBonus);
}

//To add a new player into Players Array
//Will also detect if the player is died last wave
function AddHimIntoPlayers(Pawn P)
{
	local HEPlayer				instance;
	local int					PlayerIndex;
	local int					InGamePlayerIndex;
	local KFPlayerController	PlayerKFPC;
	local KFPawn_Human			PlayerKFPH;

	PlayerKFPC=KFPlayerController(P.Controller);
	PlayerKFPH=KFPawn_Human(P);
	if(PlayerKFPC==None || PlayerKFPH==None) //if he's not Human, return
		return;
		
	PlayerNumber=PlayerNumber+1; // player number +1
	PlayerIndex=PlayerNumber-1; // get player index in arry
	
	if(isAlreadyInGame(P, InGamePlayerIndex)) //If he's already in game (like he died last wave)
	{
		PlayerKFPC.ServerSay("No."$InGamePlayerIndex$" Player Respawned");
		return;
	}
	if(Players[PlayerIndex].KFPC!=PlayerKFPC)
	{
		instance.KFPC=PlayerKFPC;
		instance.KFPH=PlayerKFPH;
		Players.AddItem(instance);
	}
	Players[PlayerIndex+1].KFPC.ServerSay
		(
			"The No."$PlayerIndex+1
			$" Player"$Players[PlayerIndex+1].KFPC.PlayerReplicationInfo.PlayerName
			$" Joins Game!"
		);
}

//Initialize Players Array, add a Null instance into it
function InitPlayersArry()
{
	local HEPlayer instance;
	instance.KFPC=None;
	instance.LastTarget=None;
	instance.KFPM_Victim=None;
	instance.pShotTarget=None;
	instance.KFPH=None;
	Players.AddItem(instance);
}

//Return true if this Pawn is his LastTarget
simulated function bool isSameTarget(int PlayerIndex, Pawn P)
{
	return P==Players[PlayerIndex].LastTarget;
}

Event Tick(float DeltaTime)
{
	local int					i;
	local KFPerk				KFP;
	for(i=1; i<=PlayerNumber; ++i)
	{
		Players[i].pShotTarget=Players[i].KFPC.ShotTarget;
		
		if(Players[i].pShotTarget==None)
			return;
		
		//If ShotTarget is not the LastTarget
		if(!isSameTarget(i, Players[i].pShotTarget))
		{
			if(bIsEnableDebugMsg)
				Players[i].KFPC.ServerSay(Players[i].KFPC.PlayerReplicationInfo.PlayerName$" Aims ["$Players[i].pShotTarget$"]"); //For Debug
			Players[i].LastTarget=Players[i].pShotTarget; //Set LastTarget to ShotTarget
		}
		
		Players[i].KFPM_Victim=KFPawn_Monster(Players[i].pShotTarget);
		
		if(Players[i].KFPM_Victim==None)
		{
			return;
		}
		 //Debug Victim Zed's Head health
		if(bIsEnableDebugMsg)
			Players[i].KFPC.ServerSay
			(
				Players[i].KFPM_Victim.Name
				$" HZI_HEAD["
				$Players[i].KFPM_Victim.HitZones[HZI_HEAD].GoreHealth
				$"]"
			); //For Debug
		
		//Draw Target Debug Sphere in Solo game
		if(bIsEnableDebugSolo)
			DrawDebugSphere(Players[i].KFPM_Victim.Location, dDetectRadius, 10, 0, 255, 0);
		
		
		if(Players[i].KFPM_Victim.HitZones[HZI_HEAD].GoreHealth<=0)
		{
			/* 
				A simulated function can't exec so I put it here for a short time
			*/
			if(bIsEnableDebugMsg)
				Players[i].KFPC.ServerSay("Entered ProcessHeadShotEx()"); //For Debug
				
			/* Main Function */
			//0 for both
			if(HealingMode==0)
			{	
				if(bAllowOverClocking)
				{
					Players[i].KFPC.Pawn.Health=Players[i].KFPC.Pawn.Health+HealthHealingAmount;
					Players[i].KFPH.Armor=Players[i].KFPH.Armor+ArmourHealingAmount;
				}
				else
				{
					Players[i].KFPC.Pawn.Health=Min
					(
					Players[i].KFPC.Pawn.Health+HealthHealingAmount, 
					Players[i].KFPC.Pawn.HealthMax
					);
				
					//need to know max armor ammount
					Players[i].KFPH.Armor=Players[i].KFPH.Armor+ArmourHealingAmount;
				}
			}
			//1 for health only
			if(HealingMode==1)
			{
				if(bAllowOverClocking)
				{
					Players[i].KFPC.Pawn.Health=Players[i].KFPC.Pawn.Health+HealthHealingAmount;
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
					Players[i].KFPH.Armor=Players[i].KFPH.Armor+ArmourHealingAmount;
				}
				else
				{
					//need to know max armor ammount
					Players[i].KFPH.Armor=Players[i].KFPH.Armor+ArmourHealingAmount;
				}
			}
			++Players[i].HeadshotsInLogTime;
			
			/* Record how many headshots are done by him in Zed Time */
			bClearZedTime=True;
			if(`IsInZedTime(self))
			{
				bClearZedTime=False;
				++Players[i].TotalHsThisZedTime;
				Players[i].KFPC.ServerSay("No."$Players[i].TotalHsThisZedTime$" Headshots!");
			}
			if(bClearZedTime)
				Players[i].TotalHsThisZedTime=0;
				
			/* Clear flags */
			Players[i].pShotTarget=None;
			Players[i].KFPC.ShotTarget=None;	//Last Zed is killed, avoiding continiously healing	
		}
	}
	super.Tick(DeltaTime);
}

defaultproperties
{
}
