//=============================================================================
// Healing Extend Mutator : Healing Extend (HE) HUD Manager
// This class is written to be a replicated actor in order to gain a full control
//		of the HE HUD in client side
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
// Version 0.1.3
// Last Update Date Aug.5th 2017
//=============================================================================

class HE_HUDManager extends Actor;

//*************************************************************
//* Varirables
//*************************************************************
var KFPlayerController		KFPlayerOwner;

//*************************************************************
//* Configs
//*************************************************************

//*************************************************************
//* Replication
//*************************************************************
Replication
{
	//if( Role == Role_Authority)
		//TO-DO Configs need to deliver to clients
	if( Role < Role_Authority )
		KFPlayerOwner;
}

//*************************************************************
//* Initialization
//*************************************************************
simulated function PostBeginPlay()
{
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Entered PostBeginPlay.");
	LogNetworkStatus();
	`log("[HE_HUDManager:"$WorldInfo.NetMode$"]End PostBeginPlay function.");	
		
	super.PostBeginPlay();
}

//*************************************************************
//* Helper Functions
//*************************************************************
/**
 * Helper function to get the LocalPlayer
 */
simulated function PlayerController GetLPPC()
{
	local LocalPlayer LocalPlayerOwner;

	LocalPlayerOwner = class'Engine'.static.GetEngine().GamePlayers[0];
	if (LocalPlayerOwner == none)
	{
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]WARNING: Find NONE LocalPlayer !");
		return none;
	}
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Return LocalPlayer.Actor "$LocalPlayerOwner.Actor);
	return LocalPlayerOwner.Actor;
}

//To get KFPlayerOwner
simulated function GetKFPC()
{
	KFPlayerOwner = KFPlayerController( GetLPPC() );
	if(KFPlayerOwner == None)
	{
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]WARNING: Get no KFPlayerOwner !");
		return;
	}
	return;
}

//*************************************************************
//* Misc (Also contains some misc client & server function)
//*************************************************************
//Log Network Status for debug
simulated function LogNetworkStatus()
{
	local int i;
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Current Role="$Role);
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Current RemoteRole="$RemoteRole);
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Current Owner="$Owner);
	for(i=0;i< class'Engine'.static.GetEngine().GamePlayers.Length;++i)
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]DisplayAll LP:"$class'Engine'.static.GetEngine().GamePlayers[i].Name);
}

//Only server can do this func, to check if the KFPlayerOwner is
//rep to the server
reliable server function LogRepStatus()
{
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Server Side Rep Current KFPlayerOwner="$KFPlayerOwner);
}

//*************************************************************
//* Client Functions Main
//*************************************************************
//reliable client function ClientSetHUD(class<HE_HUDBase> HE_HUDType)
//Let client set HUD to HE_HUD
reliable client function ClientSetHUD(class<HE_HUDBase> HE_HUDType)
{
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Enter ClientSetHUD.");
	//If it's client side or it's standalone solo game
	if(Role < Role_Authority || WorldInfo.NetMode == NM_Standalone)
	{
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Getting KFPC...");
		GetKFPC();
		LogRepStatus();
		//Create HE_HUD for LocalPlayer
		KFPlayerOwner.ClientSetHUD(HE_HUDType);
		//Create his HUD on Client side && also Standalone
		if(HE_HUDBase(KFPlayerOwner.myHUD)==None)
		{
			`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Error spawning a new HE_HUD hud! Pre-exit the PostBeginPlay Function !");
			super.PostBeginPlay();
			return;
		}
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Spawned a new HUD "$KFPlayerOwner.myHUD$" for "$KFPlayerOwner.PlayerReplicationInfo.PlayerName);
		//Create MovieHUD
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Creating New MovieHUD...");
		HE_HUDBase(KFPlayerOwner.myHUD).CreateHUDMovie( False );
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Setting New GFxHUD...");
		KFPlayerOwner.SetGFxHUD(HE_HUDBase(KFPlayerOwner.myHUD).HudMovie);	
	}
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Current KFPlayerOwner="$KFPlayerOwner);
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]End ClientSetHUD.");
}

//*************************************************************
//* Server Functions
//*************************************************************

defaultproperties
{
	RemoteRole=Role_SimulatedProxy
}