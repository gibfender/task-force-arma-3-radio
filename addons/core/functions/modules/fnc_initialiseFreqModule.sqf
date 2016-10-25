#include "script_component.hpp"

/*
    Name: TFAR_fnc_initialiseFreqModule

    Author(s):
        L-H

    Description:
        Initialises variables based on module settings.

    Parameters:

    Returns:
        Nothing

    Example:

*/

params [
    ["_logic", objNull, [objNull]],
    ["_units", [], [[]]],
    ["_activated", true, [true]]
];

if (_activated) then {
    if (count _units == 0) exitWith { hint "TFAR - No units set for Frequency Module";diag_log "TFAR - No units set for Frequency Module";};
    if (!isServer) exitWith {};
    private _swFreq = false call TFAR_fnc_generateSRSettings;
    private _freqs = call compile (_logic getVariable "PrFreq");
    private _randomFreqs = [TFAR_MAX_CHANNELS,TFAR_MAX_SW_FREQ,TFAR_MIN_SW_FREQ,TFAR_FREQ_ROUND_POWER] call TFAR_fnc_generateFrequencies;
    while {count _freqs < TFAR_MAX_CHANNELS} do {
        _freqs set [count _freqs, _randomFreqs select (count _freqs)];
    };
    _swFreq set [2,_freqs];

    private _lrFreq = false call TFAR_fnc_generateLrSettings;
    _freqs = call compile (_logic getVariable "LrFreq");
    _randomFreqs = [TFAR_MAX_LR_CHANNELS,TFAR_MAX_ASIP_FREQ,TFAR_MIN_ASIP_FREQ,TFAR_FREQ_ROUND_POWER] call TFAR_fnc_generateFrequencies;
    while {count _freqs < TFAR_MAX_LR_CHANNELS} do{
        _freqs set [count _freqs, _randomFreqs select (count _freqs)];
    };
    _lrFreq set [2,_freqs];

    //Make unique list of groups. In case player assigned module to multiple units of same group
    private _groups = [];
    {
        _groups pushBackUnique (group _x);
        true;
    } count _units;

    {
        if (!isNil (_x getVariable "tf_sw_frequency")) then {hint format["TFAR - tf_sw_frequency already set, might be assigning a group (%1) to multiple frequency modules. Or frequency modules to multiple units in the same group.", (group _x)];diag_log format["TFAR - tf_sw_frequency already set, might be assigning a group (%1) to multiple frequency modules.", (group _x)];};

        if (!isNil (_x getVariable "tf_lr_frequency")) then {hint format["TFAR - tf_lr_frequency already set, might be assigning a group (%1) to multiple frequency modules. Or frequency modules to multiple units in the same group.", (group _x)];diag_log format["TFAR - tf_lr_frequency already set, might be assigning a group (%1) to multiple frequency modules.", (group _x)];};

        _x setVariable ["tf_sw_frequency", _swFreq, true];
        _x setVariable ["tf_lr_frequency", _lrFreq, true];

        true;
    } count _groups;
};

true