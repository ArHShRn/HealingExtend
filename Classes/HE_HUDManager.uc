class HE_HUDManager extends Actor;
//*************************************************************
//* Varirables
//*************************************************************
var class<HUD>				HE_HUDType;

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
function Init(optional LocalPlayer LocPlay)
{
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Entered Init.");
	//Todo
}

simulated function PostBeginPlay()
{
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Entered PostBeginPlay.");
	
	//If it's client side or it's standalone solo game
	if(Role < Role_Authority || WorldInfo.NetMode == NM_Standalone)
	{
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Client Getting KFPC...");
		GetKFPC();
		LogRepStatus();
		//Create HE_HUD for LocalPlayer
		KFPlayerOwner.ClientSetHUD(HE_HUDType);
		//Create his HUD on Client side && also Standalone
		if(HE_HUD(KFPlayerOwner.myHUD)==None)
		{
			`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Error spawning a new HE_HUD hud! Pre-exit the PostBeginPlay Function !");
			super.PostBeginPlay();
			return;
		}
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Spawned a new HUD "$HE_HUD(KFPlayerOwner.myHUD)$" for "$KFPlayerOwner.PlayerReplicationInfo.PlayerName);
		//Create MovieHUD
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Creating New MovieHUD...");
		HE_HUD(KFPlayerOwner.myHUD).CreateHUDMovie( False );
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Setting New GFxHUD...");
		KFPlayerOwner.SetGFxHUD(HE_HUD(KFPlayerOwner.myHUD).HudMovie);	
	}
	
	LogNetworkStatus();
	
	`log("[HER:"$WorldInfo.NetMode$"]End PostBeginPlay function.");	
		
	super.PostBeginPlay();
}

//*************************************************************
//* Helper Functions
//*************************************************************
/**
 * Helper function to get the LocalPlayer
 */
simulated function PlayerController GetPC()
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
	KFPlayerOwner = KFPlayerController( GetPC() );
	if(KFPlayerOwner == None)
	{
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]WARNING: Get no KFPlayerOwner !");
		return;
	}
	return;
}

//*************************************************************
//* Misc
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
	`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Current KFPlayerOwner="$KFPlayerOwner);
}

//Only server can do this func, to check if the KFPlayerOwner is
//rep to the server
function LogRepStatus()
{
	if(WorldInfo.NetMode == NM_Standalone)
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Standalone Current KFPlayerOwner="$KFPlayerOwner);
	else
		`log("[HE_HUDManager:"$Worldinfo.NetMode$"]Server Side Rep Current KFPlayerOwner="$KFPlayerOwner);
}

//*************************************************************
//* Client Functions
//*************************************************************

//*************************************************************
//* Server Functions
//*************************************************************

defaultproperties
{
	RemoteRole=Role_SimulatedProxy
	
	HE_HUDType=class'HealingExtend.HE_HUD'
}