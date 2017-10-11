//=============================================================================
// Healing Extend Mutator : Data Structure
// This class stores the basic data structures and variables of the mut
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.1
//
// Last Update Date Oct.11th 2017
//=============================================================================
//=================================KFPC.PWRI========================================
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

/**
  *Every player in the game should have a Healing Extend structure
  *to restore the info he has
*/
struct HEPlayer
{
	var Pawn					pShotTarget;			//	A shot target pawn he owns, Use to avoidi checking ShotTarget frequently
	var Pawn					LastTarget;				//	His last zed target
	var KFPawn_Monster			KFPM_Victim;			//	Zed victim who damaged by him
	var KFWeapon				KFWeap;					//  His Weap in hand
	
	var KFPlayerReplicationInfo	KFPRI;					//  His Player Replication Info
	var KFPlayerController		KFPC;					//	His KFPlayerController class
	var KFPawn_Human			KFPH;					//	His KFPawn_Human
	var class<KFPerk>			LastPerk;
	
	var HE_HUDManager			HUDManager;				//	His HUD Manager
	var HE_TraderManager		TraderManager;
	var HE_ChatController		ChatController;
	
	var int						Index;					//  Shows his Index
	var int						fLastHSC;				//  His last AAR Headshots Ammout
	//var int						ConfigNotify;
	var float					HealthDecrement;		//  Temply stores the health delta
	var float					ArmorDecrement;			//  Temply stores the armor	delta
	
	var bool					bIsEpt;
};

struct HEVersionInfo
{
	var string					ThisMutatorName;
	var string					AuthorNickname;
	var string					AuthorSteamcommunityURL;
	var string					Version;
	var string					LastUpdate;
};

struct HECommand
{
	var string					CommandHead;
	var string					UserName;
	var string					Argument;
	var string					Parameter;
	var string					Value;
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

struct HE_HUDReplicationInfo
{
	var class<KFPerk>			PlayerPerk;
};

struct HEConfig
{
	//Mutator Version
	var HEVersionInfo			HEVI;
	//System Variable Configs
	var float					fCurrentRegenRate;
	var bool					bAllowOverClocking;	
	var bool					bInitedConfig;
	var bool					bRecoverAmmo;	
	var bool					bEnableAAR_Headshots;
	var bool					bGetDosh;
	 
	//Common Settings
	var int						HealthHealingAmount;
	var int						ArmourHealingAmount;
	var int						AmmoRecoverAmout;
	var int						BonusDosh;
	var int						OverclockLimitHealth;
	var int						OverclockLimitArmour;

};

defaultproperties
{
}