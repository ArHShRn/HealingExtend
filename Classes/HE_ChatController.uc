//=============================================================================
// Healing Extend Mutator : Chat Controller
// This class get chatbox's chat messages and act as the player says something
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.3
//
// Last Update Date Jan.26th 2017
//=============================================================================
class HE_ChatController extends BroadcastHandler
	Config(HE_ChatController);
	
var HE_Main MyHEMain;

var BroadcastHandler PreBroadcastHandler; //Compability to RPW

//Initialize HE_Main Class
//WARNING: Must be compatible with RPW!
function InitHEClass(HE_Main HE_MainObj) {
	MyHEMain = HE_MainObj;
	PreBroadcastHandler = MyHEMain.MyKFGI.BroadcastHandler;
	MyHEMain.MyKFGI.BroadcastHandler = self;
	`log("[HECC]Compability To Class "$PreBroadcastHandler.Name);
}

simulated function PostBeginPlay()
{
	local GameViewportClient LocalGVC;
	super.PostBeginPlay();
	LocalGVC = class'Engine'.static.GetEngine().GameViewport;
	if(LocalGVC == None)
		return;
	
	LocalGVC.ViewportConsole.OutputTextLine("[HECC]WorldInfo.NetMode="$WorldInfo.NetMode);
	LocalGVC.ViewportConsole.OutputTextLine("[HECC]Role="$Role);
	LocalGVC.ViewportConsole.OutputTextLine("[HECC]RemoteRole="$RemoteRole);
	LocalGVC.ViewportConsole.OutputTextLine("[HECC]Owner="$Owner);
}

//Override the super, get an entrance for chat command
//WARNING: Must be compatible with RPW!
function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type ) {
	//This BH's workflow		
	if (MyHEMain!=None) {
		if (SenderPRI!=None) {
			if (PlayerController(SenderPRI.Owner)==Receiver) {
					MyHEMain.Broadcast(SenderPRI, Receiver, Msg);
			}
		}
	}
	if(MyHEMain.StopBroadcast(Msg)) return;
	PreBroadcastHandler.BroadcastText(SenderPRI,Receiver,Msg,Type);
}

defaultproperties
{	
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
}