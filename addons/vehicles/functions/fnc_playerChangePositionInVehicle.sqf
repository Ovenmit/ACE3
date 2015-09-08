/*
 * Author: joko // Jonas
 * This Code will be Executed if the player Change a Position in Vehicle or getIn a Vehicle
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, car] call ace_vehicles_fnc_playerChangePosition
 *
 * Public: No
 */
#include "script_component.hpp"
scopeName "main";
if (GVAR(ProgressIsRunning)) exitWith {};

private ["_haveIllegalPrimaryWeapon", "_haveIllegalSecondaryWeapon", "_haveIllegalBackpack", "_vehicle", "_"];

params ["_kindOf", "_args"];
_args params ["_unit", "_index"];

_haveIllegalPrimaryWeapon = false;
_haveIllegalSecondaryWeapon = false;
_haveIllegalBackpack = false;

_vehicle = vehicle _unit;
if (_vehicle isKindOf "air" || _vehicle isKindOf "car" || _vehicle isKindOf "tank") exitWith {};

_primaryWeapon = primaryWeapon _unit;
_secondaryWeapon = secondaryWeapon _unit;
_backpack = backpack _unit;

_currentPrimaryWeaponType = getText(configFile >> "CfgWeapons" >> typeOf _primaryWeapon >> QGVAR(Class));
_currentSecondaryWeaponType = getText(configFile >> "CfgWeapons" >> typeOf _secondaryWeapon >> QGVAR(Class));
_currentBackpackType = getText(configFile >> "CfgVehicles" >> typeOf _backpack >> QGVAR(Class));

_allowedGear = switch _unit do {
    case driver _vehicle: {
        getArray(configFile >> "CfgVehicles" >> typeOf _vehicle >> QGVAR(AllowedClasses))
    };
    case gunner _vehicle; case commander _vehicle: {
        if (typeName _index == "OBJECT") then {
            _index = [_unit] call EFUNC(common,getTurretIndex);
        };
        
        _FFVTurrets = allTurrets [_vehicle, true] - allTurrets [_vehicle, false];
        if(_index in _FFVTurrets) exitWith {[]}; //FFV turret

        _config = [(configFile >> "CfgVehicles" >> typeOf _vehicle), _index] call EFUNC(common,getTurretConfigPath);
        getArray(_config >> QGVAR(AllowedClasses))
    };
    default { [] };
};

if (!_allowedGear isEqualTo []) exitWith {};

_haveIllegalPrimaryWeapon = if (_currentPrimaryWeaponType != "") then {
    !(_currentPrimaryWeaponType in _allowedGear)
} else {
    false
};

_haveIllegalSecondaryWeapon = if (_currentSecondaryWeaponType != "") then {
    !(_currentSecondaryWeaponType in _allowedGear)
} else {
    false
};

_haveIllegalBackpack = if (_currentBackpackType != "") then {
     !(_currentBackpackType in _allowedGear)
} else {
    false
};


if !(_haveIllegalPrimaryWeapon || _haveIllegalSecondaryWeapon || _haveIllegalBackpack) exitWith {};

_param = [];
if (_haveIllegalPrimaryWeapon) then {
    _param pushBack [_unit, _primaryWeapon, 0];
};

if (_haveIllegalSecondaryWeapon) then {
    _param pushBack [_unit, _secondaryWeapon, 0];
};

if (_haveIllegalBackpack) then {
    _param pushBack [_unit, _backpack, 1];
};

if (_param isEqualTo []) exitWith {};
_param call FUNC(dropGear);