//=============================================================================
// Healing Extend Mutator : Healing Extend (HE) HUD Manager
// This class is written to be a replicated actor in order to gain a full control
//		of the HE HUD in client side
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.0.1
// -Remove skill stuffs
// -Standard HUDs, no seperated HUDs per perk
//
// Last Update Date Aug.31th 2017
//=============================================================================

class HE_HUDManager extends Actor
	config(HE_HUDManager);

//*************************************************************
//* Varirables
//*************************************************************
//Mutator Version Info
var config HEVersionInfo HEVI;
var HEVersionInfo Editable_HEVI;

//Client Side variables
var HE_HUDBase MyHE_HUD;		//player's HE_HUD
var repnotify KFPlayerController KFPlayerOwner;	//KF Player Onwer

//*************************************************************
//* Configs
//*************************************************************

//*************************************************************
//* Replication
//*************************************************************
Replication
{
	if( Role < Role_Authority && WorldInfo.NetMode != NM_Standalone)
		KFPlayerOwner;
}

simulated function ReplicatedEvent(name VarName)
{	
	if(VarName == 'KFPlayerOwner')
		`log("---[HE_HUDManager::ReplicatedEvent]REPNOTIFY: KFPlayerOwner is replicated.");
}

//*************************************************************
//* Initialization
//*************************************************************
simulated function PostBeginPlay()
{
	//Force init
	InitBasicValues();
	super.PostBeginPlay();
}

function InitBasicValues()
{
	//Muatator Version Info
	Editable_HEVI.ThisMutatorName="HE_HUDManager";
	Editable_HEVI.AuthorNickname="ArHShRn";
	Editable_HEVI.AuthorSteamcommunityURL="http://steamcommunity.com/id/ArHShRn/";
	Editable_HEVI.Version="Release 1.0.1";
	Editable_HEVI.LastUpdate="Sept.15th 2017 07:31 AM";
	HEVI=Editable_HEVI;
	
	SaveConfig();
}
//*************************************************************
//* Helper Functions
//*************************************************************
/**
 * Helper function to get the LocalPlayer
 */
//LocalPlayer is created right after the game entered
//Just like PostBeginPlay, even before the KFPC is created
simulated function PlayerController GetLPPC()
{
	local LocalPlayer LocalPlayerOwner;

	LocalPlayerOwner = class'Engine'.static.GetEngine().GamePlayers[0];
	if (LocalPlayerOwner == none)
	{
		`log("[---HE_HUDManager::GetLPPC]WARNING: Find NONE LocalPlayer !");
		return none;
	}
	`log("---[HE_HUDManager::GetLPPC]Return LocalPlayer.Actor "$LocalPlayerOwner.Actor);
	return LocalPlayerOwner.Actor;
}

//To get KFPlayerOwner
//Attention: KFPlayerController is only created after ModifyPlayer!
//So should be the HUD !
simulated function GetKFPC()
{
	KFPlayerOwner = KFPlayerController( GetLPPC() );
	if(KFPlayerOwner == None)
	{
		`log("---[HE_HUDManager::GetKFPC]WARNING: Get no KFPlayerOwner !");
		return;
	}
}

simulated function AddChatLine(string str)
{
	KFPlayerOwner.MyGFxHUD.HudChatBox.AddChatMessage(str, class 'KFLocalMessage'.default.EventColor);
}

reliable client function ClientAddChatLine(string str, string HexVal)
{
	KFPlayerOwner.MyGFxHUD.HudChatBox.AddChatMessage(str, HexVal);
}
//*************************************************************
//* Misc (Also contains some misc client & server function)
//*************************************************************
//Log Network Status for debug
simulated function LogNetworkStatus()
{
	`log("---[HE_HUDManager::LogNetworkStatus]Current Role="$Role);
	`log("---[HE_HUDManager::LogNetworkStatus]Current RemoteRole="$RemoteRole);
	if(Role == ROLE_Authority && KFPlayerOwner == None)
		`log("---[HE_HUDManager::LogNetworkStatus]WARNING: Current KFPlayerOwner failed to be replicated to Server!");
	else
		`log("---[HE_HUDManager::LogNetworkStatus]Current KFPlayerOwner="$KFPlayerOwner);
	`log("---[HE_HUDManager::LogNetworkStatus]Current Owner="$Owner);
}

//*************************************************************
//* Client Functions Main
//*************************************************************
//Let client set HUD to HE_HUD
//Attention: In Standalone SOLO game, KFGFXMoviePlayer should be created manually while
//	both the HUD and KFGFXMoviePlayer are created together in Server side
reliable client function ClientSetHUD()
{	
	//If it's client side or it's standalone solo game
	if(Role < Role_Authority || WorldInfo.NetMode == NM_Standalone)
	{
		`log("---[HE_HUDManager::ClientSetHUD]Getting KFPC...");
		
		GetKFPC();
		
		//Create HE_HUD for LocalPlayer
		//Perk needs checking in the HUD_Base instead of spawning in every ModifyPlayer()
		//To-do: Currently there's only standard HUD, in later version there will be various kinds of HUD types for each perk
		KFPlayerOwner.ClientSetHUD(class'HealingExtend.HE_HUDBase');
			
		//Create his KFGfxMoviePlayer on Client side && also Standalone
		if(HE_HUDBase(KFPlayerOwner.myHUD)==None)
		{
			`log("---[HE_HUDManager::ClientSetHUD]Error spawning a new HE_HUD hud!");
			return;
		}
		`log("---[HE_HUDManager::ClientSetHUD]Spawned a new HUD "$KFPlayerOwner.myHUD$" for "$KFPlayerOwner.PlayerReplicationInfo.PlayerName);
		//Create KFGFXMoviePlayer
		HE_HUDBase(KFPlayerOwner.myHUD).CreateHUDMovie( False );
		KFPlayerOwner.SetGFxHUD(HE_HUDBase(KFPlayerOwner.myHUD).HudMovie);	
		`log("---[HE_HUDManager::ClientSetHUD]New KFGFxMoviePlayer is successfully set.");
	}
	MyHE_HUD=HE_HUDBase(KFPlayerOwner.myHUD);
	LogNetworkStatus();	
	
	`log("---[HE_HUDManager::ClientSetHUD]End ClientSetHUD.");
}

//*************************************************************
//* Server Functions
//*************************************************************


//*************************************************************
//* Skill Functions
//*************************************************************
//To-do


defaultproperties
{
	RemoteRole=Role_AutonomousProxy
}