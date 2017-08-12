//=============================================================================
// Healing Extend Mutator : Data Structure
// This class stores the basic data structures and variables of the mut
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
// Version 0.1.3
// Last Update Date Aug.5th 2017
//=============================================================================
//=================================KFPC========================================
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
class HE_DataStructure extends Object
	Abstract;

/* Every player in the game should have a Healing Extend structure
	to restore the info he has
*/
struct HEPlayer
{
	//
	var Pawn					pShotTarget;			//	A shot target pawn he owns, Use to avoidi checking ShotTarget frequently
	var Pawn					LastTarget;				//	His last zed target
	var KFWeapon				KFWeap;					//  His Weap in hand
	var KFPlayerReplicationInfo	KFPRI;					//  His Player Replication Info
	var KFPlayerController		KFPC;					//	His KFPlayerController class
	var KFPawn_Monster			KFPM_Victim;			//	Zed victim who damaged by him
	var KFPawn_Human			KFPH;					//	His KFPawn_Human
	
	var int						Index;					//  Shows his Index
	var int						fLastHSC;				//  His last AAR Headshots Ammout
};

enum HUDCrosshairStatus
{
	HE_Good,
	HE_WeapNotGuns,
	HE_Player_Closed,
	HE_Player_Dead,
	HE_Player_NoWeap,
	HE_Player_Monster,
	HE_Player_UsingIronsight,
	HE_Player_SpecialMoveDontAllow,
	HE_NoneInit
};

enum AsCMode
{
	AsC_Default,
	AsC_CenterDot,
	AsC_OnlyDot
};

defaultproperties
{
}