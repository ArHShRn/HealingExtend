//=============================================================================
// Healing Extend Mutator : Instant Healing
// This calss provides you the possibility to recover Health 
//		for a customized health regen rate
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//=============================================================================
class HE_Main extends HE_Recover
	DependsOn(HE_Recover)
	config(HealingExtend);
//*********************************************************
//* Variables
//*********************************************************

var config float					fCurrentRegenRate;
	
var KFPlayerController				KFPC;

//*********************************************************
//* Initialization
//*********************************************************
function PostBeginPlay()
{
	if(!bInitedConfig)
	{
		`log("[HealingExtend_Main Mut:"$WorldInfo.NetMode$"]Init Basic Mutator Values...");
		InitBasicMutatorValues();
		
		`log("[HealingExtend_Main Mut:"$WorldInfo.NetMode$"]Save to config...");
		SaveConfig();
	}
	
	super.PostBeginPlay();
}

function InitBasicMutatorValues()
{
	bInitedConfig=True;
	fCurrentRegenRate=40.0;
}

function ModifyPlayer(Pawn Other)
{
	local KFPawn_Human KFPH;
	KFPH=KFPawn_Human(Other);
	KFPH.HealthRegenRate=(1/fCurrentRegenRate);
	KFPC=KFPlayerController(Other.Controller);
	`log("[HealingExtend_Main Mut:"$WorldInfo.NetMode$"]HealthRegenRate Set to "$KFPH.HealthRegenRate);
	
	super.ModifyPlayer(Other);	
}

//*********************************************************
//* Default Properties
//*********************************************************
defaultproperties
{
}