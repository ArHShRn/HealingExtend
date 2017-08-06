//=============================================================================
// Healing Extend Mutator : Instant Healing
// This is the first mutator containing in HealingExtend Mut
// 
// This mutator provides you the possibility to recover Health 
//		for a customized health regen rate
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//=============================================================================
class InstantHealing extends Mutator
	config(HealingExtend);

	var config float					fCurrentRegenRate;
	//var config float					fZedTimeRegenRate;
	var config bool						bInitedConfig;
	//var config bool						bEnableInfiniteHealingZedTime;

function InitMutator(string Options, out string ErrorMessage)
{
	if(!bInitedConfig)
	{
		InitBasicMutatorValues();
		SaveConfig();
	}
	super.InitMutator( Options, ErrorMessage );
}

function InitBasicMutatorValues()
{
	bInitedConfig=True;
	fCurrentRegenRate=40.0;
	//bEnableInfiniteHealingZedTime=True;
	
}

function PostBeginPlay()
{
	SaveConfig();
	super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{
	local KFPawn_Human KFPH;
	KFPH=KFPawn_Human(Other);
	KFPH.HealthRegenRate=(1/fCurrentRegenRate);
	super.ModifyPlayer(Other);	
}

defaultproperties
{
}