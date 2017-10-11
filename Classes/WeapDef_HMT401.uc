//=============================================================================
// Healing Extend Mutator : HMTech-401 Balanced Definition
//	This class is a balanced weapon's definition
//
// Code And Concept By ArHShRn
// http://steamcommunity.com/id/ArHShRn/
//
// Version Release 1.1.1
//
// Last Update Date Oct.11th 2017
//=============================================================================
class WeapDef_HMT401 extends KFWeaponDefinition
	abstract;

static function string GetItemName()
{return "HMTech-401 BiohaZard";}

static function string GetItemDescription()
{return "Biohazard Edition";}

static function string GetItemLocalization(string KeyName)
{
	return "HMTech-401 BiohaZard";
}

defaultproperties
{
	WeaponClassPath="HealingExtend.Weap_HMT401"

	BuyPrice=1500
	AmmoPricePerMag=40
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_MedicAssault"

	EffectiveRange=70
}
