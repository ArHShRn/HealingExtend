// Explanation:
//	Replicated Event is called when the value marking "repnotify" is changed
//	or we say, differs from Server Side or Client Side, and is called at the
//	another side where the variable is replicated to.
//	In this class we change only the variables on Server Side, and in Replication session,
//	we make variables be replicated on Server Side to Client Side and the effects are:
//
//		1.ChangeValue Function is only called on server
//		2.Two variables are replicated to client side
//		3.Replication starts when SimulatedProxy's value differs from Authority
//		4.ReplicatedEvent is called when replication has started
//		5.In this class, variables are replicated to client side, so ReplicatedEvent is
//			called on client side.
class HE_RepTest extends Actor;

var repnotify string		strTest;
var repnotify int			intTest;

Replication
{
	if(Role == ROLE_Authority)
		strTest, intTest;
}

simulated function ReplicatedEvent(name VarName)
{
	if(VarName == 'strTest')
		`log("---[HE_RepTest::ReplicatedEvent]strTest has been replicated.");
		
	if(VarName == 'intTest')
		`log("---[HE_RepTest::ReplicatedEvent]intTest has been replicated.");
}

function PostBeginPlay()
{
	intTest=0; strTest="Now:"$intTest;
	super.PostBeginPlay();
	SetTimer(1.f, True, 'ChangeValue');
}

reliable client function ClientPrint(int SevrerInt, string SevrerStr)
{
	local GameViewportClient LocalGVC;
	LocalGVC = class'Engine'.static.GetEngine().GameViewport;
	if(LocalGVC == None)
		return;
	
	intTest++; strTest="Now:"$intTest;
	LocalGVC.ViewportConsole.OutputTextLine("Client.strTest="$strTest);
	LocalGVC.ViewportConsole.OutputTextLine("Client.intTest="$intTest);
	LocalGVC.ViewportConsole.OutputTextLine("---Server.strTest="$SevrerStr);
	LocalGVC.ViewportConsole.OutputTextLine("---Server.intTest="$SevrerInt);
	LocalGVC.ViewportConsole.OutputTextLine(" ");
}

function ChangeValue()
{
	ClientPrint(intTest, strTest);
	intTest++; strTest="Now:"$intTest;
}

defaultproperties
{
	RemoteRole=ROLE_AutonomousProxy
	bAlwaysRelevant=true
}