class HE_HUD extends KFGFxHudWrapper
	Config(HealingExtend);
	
//-----------------------------------------------------------------
//Configs
//-----------------------------------------------------------------
var config bool					bShowHE_HUD;

var KFPlayerController			KFPC;
var HEPlayer					HEP;

//-----------------------------------------------------------------
//Initialization
//-----------------------------------------------------------------
//An interface can be called by outer class
simulated function InitHE_HUD(bool isInit)
{
	if(!isInit)
		InitBasicValues();
	SaveConfig();
	`log("[HE_HUD]Save to config...");
}

//Init basic values
simulated function InitBasicValues()
{
	`log("[HE_HUD]Init Basic Values...");
	bShowHE_HUD=True;
}

//Delivering KFPC into HUD to process
simulated function InitKFPC(KFPlayerController fKFPC)
{
	`log("[HE_HUD]Starting Init KFPC......");
	if(None != fKFPC)
	{
		KFPC=fKFPC;
		`log("[HE_HUD]"$fKFPC.PlayerReplicationInfo.PlayerName$" HE_HUD Set KFPC ");
	}
}

simulated function InitHEPlayer(HEPlayer fHEP)
{
	`log("[HE_HUD]Starting Init HEP......");
	HEP=fHEP;
	`log("[HE_HUD]"$fHEP.KFPC.PlayerReplicationInfo.PlayerName$" HE_HUD Set HEP of Index "$HEP.Index);
}

//-----------------------------------------------------------------
//Render Main
//-----------------------------------------------------------------
Event PostRender()
{
	super.PostRender();
	if(!bShowHE_HUD)
	{
		`log("[HE_HUD]bShowHE_HUD set to False, not render HE_HUD now");
		return;
	}
}

Event DrawHUD()
{
	super.DrawHUD();
	//Canvas.SetDrawColor(255, 255, 0);
	//Canvas.SetPos(10, 10);
	//Canvas.DrawText("---Healing Extend HUD---");
	//Canvas.SetPos(10, 12);
	//Canvas.DrawText("Headshot AAR:"$KFPC.PWRI.VectData1.X);
}

defaultproperties
{
}