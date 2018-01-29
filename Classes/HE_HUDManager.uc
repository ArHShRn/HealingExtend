//=============================================================================
// Healing Extend Mutator : Healing Extend (HE) HUD Manager
// This class is written to be a replicated actor in order to gain a full control
//		of the HE HUD in client side
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.3
// -Be connected to BroadcastHandler to control chat command
//
// Last Update Date Oct.11th 2017
//=============================================================================

class HE_HUDManager extends Actor
	config(HE_HUDManager);

//*************************************************************
//* Varirables
//*************************************************************
//Client Side variables
var HE_HUDBase MyHE_HUD;		//player's HE_HUD
var repnotify KFPlayerController KFPlayerOwner;	//KF Player Onwer
var repnotify bool bStartGame;

var GameViewportClient		LocalGVC;
var Console					LocalC;

//*************************************************************
//* Configs
//*************************************************************

//*************************************************************
//* Replication
//*************************************************************
Replication
{
	if( Role < Role_Authority && WorldInfo.NetMode != NM_Standalone)
		KFPlayerOwner, bStartGame;
}

simulated function ReplicatedEvent(name VarName)
{	
	if(VarName == 'KFPlayerOwner')
		`log("[HE_HUDManager]REPNOTIFY: KFPlayerOwner is replicated.");
	if(VarName == 'bStartGame')
		`log("[HE_HUDManager]REPNOTIFY: bStartGame is replicated.");
}

//*************************************************************
//* Initialization
//*************************************************************
simulated function PreBeginPlay()
{
	super.PreBeginPlay();
}

//PostBeginPlay
//Get console, log status
//ATTENTION: localKFPC should be got at ModifyPlayer
//				Or it will be set to None
simulated function PostBeginPlay()
{
	//If it's client side or standalone game
	//Online game: Server side manager shouldn't have any LocalPlayer
	//	and nerver will it.
	if(Role < Role_Authority || WorldInfo.NetMode == NM_Standalone)
	{
		//Get LocalGVC to search for the player chat messages in console
		LocalGVC=class'GameEngine'.static.GetEngine().GameViewport;
		if(LocalGVC != None)
		{
			LocalC = LocalGVC.ViewportConsole;
			if(LocalC != None)
				`log("[HE_HUDManager]Get a local console.");
		}
		else
			`log("[HE_HUDManager]Error getting a local console!");
	}
	super.PostBeginPlay();
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
		`log("[HE_HUDManager]WARNING: Find NONE LocalPlayer !");
		return none;
	}
	`log("[HE_HUDManager]Return LocalPlayer.Actor "$LocalPlayerOwner.Actor);
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
		`log("[HE_HUDManager::GetKFPC]WARNING: Get no KFPlayerOwner !");
		return;
	}
}

//Add a chat line to KFPlayerOwner's ChatBox
simulated function AddChatLine(coerce string Msg, optional string MsgColor = "42bbbc") //Cyan
{
	KFPlayerOwner.MyGFxHUD.HudChatBox.AddChatMessage(Msg, MsgColor);
}

//Print sth in console
simulated function Print(coerce string message, optional bool autoPrefix = true )
{
	if ( autoPrefix )
	{
		message = "[HE HUD]"$message;
	}

	if ( LocalGVC != None )
	{
		LocalGVC.ViewportConsole.OutputTextLine(message);
	}
}

//Print console messages only in one client
reliable client function ClientPrint(coerce string str, optional bool autoFix=False)
{
	if(KFPlayerOwner == None)
		return;
	Print(str, autoFix);
}
//*************************************************************
//* Misc (Also contains some misc client & server function)
//*************************************************************
//Log Network Status for debug
simulated function LogNetworkStatus()
{
	`log("[HE_HUDManager]Current Role="$Role);
	`log("[HE_HUDManager]Current RemoteRole="$RemoteRole);
	if(Role == ROLE_Authority && KFPlayerOwner == None)
		`log("[HE_HUDManager]WARNING: Current KFPlayerOwner failed to be replicated to Server!");
	else
		`log("[HE_HUDManager]Current KFPlayerOwner="$KFPlayerOwner);
	`log("[HE_HUDManager]Current Owner="$Owner);
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
		GetKFPC();
		
		//Create HE_HUD for LocalPlayer
		//Perk needs checking in the HUD_Base instead of spawning in every ModifyPlayer()
		//To-do: Currently there's only standard HUD, in later version there will be various kinds of HUD types for each perk
		KFPlayerOwner.ClientSetHUD(class'HealingExtend.HE_HUDBase');
			
		//Create his KFGfxMoviePlayer on Client side && also Standalone
		if(HE_HUDBase(KFPlayerOwner.myHUD)==None)
		{
			`log("[HE_HUDManager]Error spawning a new HE_HUD hud!");
			return;
		}
		`log("[HE_HUDManager]Spawned a new HUD "$KFPlayerOwner.myHUD$" for "$KFPlayerOwner.PlayerReplicationInfo.PlayerName);
		//Create KFGFXMoviePlayer
		HE_HUDBase(KFPlayerOwner.myHUD).CreateHUDMovie( False );
		KFPlayerOwner.SetGFxHUD(HE_HUDBase(KFPlayerOwner.myHUD).HudMovie);	
		`log("[HE_HUDManager]New KFGFxMoviePlayer is successfully set.");
	}
	MyHE_HUD=HE_HUDBase(KFPlayerOwner.myHUD);
	MyHE_HUD.SetHUDManager(self);
	LogNetworkStatus();	
}

//*************************************************************
//* Server Functions
//*************************************************************


//*************************************************************
//* Skill Functions
//*************************************************************
//To-do
//Global ChatLine message notification
reliable server function GlobalChatLineMessage(coerce string msg)
{
	local HE_HUDManager instance;
	ForEach WorldInfo.AllActors(class'HE_HUDManager', instance)
		instance.ClientAddChatLine(msg, "00aeff");
}

//Global HUD Center message notificaion
reliable server function GlobalHUDMessage(coerce string msg)
{
	local HE_HUDManager instance;
	ForEach WorldInfo.AllActors(class'HE_HUDManager', instance)
		instance.ClientHUDMessage(msg);
}

//Implement of GlobalChatLineMessage, a client function
reliable client function ClientAddChatLine(coerce string str, optional string MsgColor = "42bbbc")
{
	KFPlayerOwner.MyGFxHUD.HudChatBox.AddChatMessage(str, MsgColor);
}

//Implement of GlobalHUDMessage, a client function
reliable client function ClientHUDMessage(coerce string msg)
{
	MyHE_HUD.DrawCenterMsg(msg);
}

//Client Play Sound
reliable client function ClientPlaySoundFromTheme(name EventName, optional name SoundThemeName='default')
{
	KFPlayerOwner.MyGFxManager.PlaySoundFromTheme(EventName, SoundThemeName);
}

defaultproperties
{
	RemoteRole=Role_AutonomousProxy
	
	bStartGame=False
}