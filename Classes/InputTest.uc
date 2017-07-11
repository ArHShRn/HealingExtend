class InputTest extends Mutator;

var KFPawn_Human KFPH_This;
var KFPlayerController KFPC;

function PostBeginPlay()
{
	super.PostBeginPlay();
}

function ModifyPlayer(Pawn Other)
{
	KFPH_This=KFPawn_Human(Other);
}

Event Tick(float DeltaTime)
{
	if(KFPH_This!=None)
	{
		KFPC=KFPlayerController(KFPH_This.Controller);
		KFPC.TeamMessage(KFPC.PlayerReplicationInfo, "Instigator="$Instigator$"||Location="$Location$"||Instigator Loc="$Instigator.Location, 'Event');
	}
	super.Tick(DeltaTime);
}

defaultproperties
{
}