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
	var Pawn					pShotTarget;			//	A shot target pawn he owns
	var KFPawn_Human			KFPH;					//	His KFPawn_Human
	var int						HeadshotsInLogTime;		//  How many head shots are done by him in dLogTime
};
	//System
	var config int				dLogTime;				// Set how much time to log the headshot been done and health been healed
	var config bool				bEnableHeadshotCount;	// Set if it's enabled to see how many head shots are done by him every dLogTim
	
	//Debug
	var config float			dDetectRadius;			// Set this to detect per head shot
	var config bool				bIsEnableDebugSolo;		// Set if it's enabled to see what target he's aiming at in SOLO game

	//GamePlay
	var array<HEPlayer>			Players;
	var int						PlayerNumber;			//How many players are in the game
	
	//Settings
	var config int				HealthHealingAmount;
	var config int				ArmourHealingAmount;
	var config int				HealingMode;			// 0 for both, 1 for health only, 2 for armour only
	
function PostBeginPlay()
{
	SaveConfig();
	
	PlayerNumber=0;
	InitPlayersArry();
	
	if(bEnableHeadshotCount)
		SetTimer(dLogTime, True, 'LogHeadshots');
	super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{
	//Add this player in to Players array if he's new in this game
	AddHimIntoPlayers(Other);
	super.ModifyPlayer(Other);
}

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

function AddHimIntoPlayers(Pawn P)
{
	local HEPlayer				instance;
	local int					PlayerIndex;
	local KFPlayerController	PlayerKFPC;
	
	PlayerKFPC=KFPlayerController(P.Controller);
	if(PlayerKFPC==None) //if he's not KFPC, return
		return;
		
	PlayerNumber=PlayerNumber+1; // player number +1
	PlayerIndex=PlayerNumber-1; // get player index in arry
	if(Players[PlayerIndex].KFPC!=PlayerKFPC)
	{
		instance.KFPC=PlayerKFPC;
		Players.AddItem(instance);
	}
	Players[PlayerIndex+1].KFPC.ServerSay
		(
		"The No."$PlayerIndex+1
		$" Player"$Players[PlayerIndex+1].KFPC.PlayerReplicationInfo.PlayerName
		$" Joins Game!"
		);
}

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

function bool isSameTarget(int PlayerIndex, Pawn P)
{
	return P==Players[PlayerIndex].LastTarget;
}

function bool isHeadBeenShot(KFPawn_Monster ThisMst)
{
	return ThisMst.HitZones[HZI_HEAD].bPlayedInjury;
}

Event Tick(float DeltaTime)
{
	local int i;
	for(i=1; i<=PlayerNumber; ++i)
	{
		Players[i].pShotTarget=Players[i].KFPC.ShotTarget;
		if(Players[i].pShotTarget==None)
			return;
			
		if(!isSameTarget(i, Players[i].pShotTarget))
		{
			if(bIsEnableDebugSolo)
				Players[i].KFPC.ServerSay(Players[i].KFPC.PlayerReplicationInfo.PlayerName$" Aims ["$Players[i].pShotTarget$"]"); //For Debug
			Players[i].LastTarget=Players[i].pShotTarget;
		}
		
		Players[i].KFPM_Victim=KFPawn_Monster(Players[i].pShotTarget);
		if(Players[i].KFPM_Victim==None)
			return;
			
		if(bIsEnableDebugSolo)
			DrawDebugSphere(Players[i].KFPM_Victim.Location, dDetectRadius, 10, 0, 255, 0);
	
		if(isHeadBeenShot(Players[i].KFPM_Victim))
			ProcessHeadShotEx(i, Players[i].KFPM_Victim, Players[i].KFPC);
	}
	super.Tick(DeltaTime);
}

function ProcessHeadShotEx(int PlayerIndex, KFPawn_Monster Victim, KFPlayerController KFPC)
{	
	KFPC.Pawn.Health=Min(KFPC.Pawn.Health+HealthHealingAmount, KFPC.Pawn.HealthMax);
	++Players[PlayerIndex].HeadshotsInLogTime;
	Players[PlayerIndex].pShotTarget=None; 
	Players[PlayerIndex].KFPC.ShotTarget=None;	//Last Zed is killed, avoiding continiously healing
}


defaultproperties
{
}