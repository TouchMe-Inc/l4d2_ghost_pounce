#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <sdktools>


public Plugin myinfo =
{
	name        = "GhostPounce",
	author      = "TouchMe",
	description = "Adds the ability to use dash in ghost mode",
	version     = "build_0000",
	url         = "https://github.com/TouchMe-Inc/l4d2_ghost_pounce"
}


#define TEAM_INFECTED           3


ConVar
	g_cvHorizontalMultiplier = null,
	g_cvVerticalValue = null
;

float
	g_fHorizontalMultiplier = 0.0,
	g_fVerticalValue = 0.0
;

/**
 *
 */
public void OnPluginStart()
{
	/*
	* Create ConVars.
	*/
	g_cvHorizontalMultiplier = CreateConVar("sm_ghost_pounce_horizontal_multiplier", "3.5");
	g_cvVerticalValue        = CreateConVar("sm_ghost_pounce_vertical_value", "600.0");

	/*
	 * Hook ConVars.
	 */
	HookConVarChange(g_cvHorizontalMultiplier, OnHorizontalMultiplierChanged);
	HookConVarChange(g_cvVerticalValue, OnVerticalValueChanged);

	/*
	 * Cache ConVars.
	 */
	g_fHorizontalMultiplier  = GetConVarFloat(g_cvHorizontalMultiplier);
	g_fVerticalValue         = GetConVarFloat(g_cvVerticalValue);
}

/**
 *
 */
void OnHorizontalMultiplierChanged(ConVar convar, const char[] sOldValue, const char[] sNewValue) {
	g_fHorizontalMultiplier = GetConVarFloat(convar);
}

/**
 *
 */
void OnVerticalValueChanged(ConVar convar, const char[] sOldValue, const char[] sNewValue) {
	g_fVerticalValue = GetConVarFloat(convar);
}

/**
 *
 */
public Action OnPlayerRunCmd(int iClient, int& iButtons, int& impulse, float vel[3], float angles[3], int& weapon)
{
	if (~iButtons & IN_RELOAD
	|| !IsClientInfected(iClient)
	|| !IsClientGhost(iClient)
	|| !IsEntOnGround(iClient)) {
		return Plugin_Continue;
	}

	float vVelocity[3]; GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", vVelocity);

	if (vVelocity[0] == 0 && vVelocity[1] == 0) {
		return Plugin_Continue;
	}

	vVelocity[0] *= g_fHorizontalMultiplier;
	vVelocity[1] *= g_fHorizontalMultiplier;
	vVelocity[2] = g_fVerticalValue;

	TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, vVelocity);

	return Plugin_Continue;
}

/**
 *
 */
bool IsEntOnGround(int iEnt) {
	return (GetEntPropEnt(iEnt, Prop_Data, "m_hGroundEntity") != -1);
}

/**
 * Returns whether the player is infected.
 */
bool IsClientInfected(int iClient) {
	return (GetClientTeam(iClient) == TEAM_INFECTED);
}

/**
 * Is the player a ghost?
 */
bool IsClientGhost(int iClient) {
	return view_as<bool>(GetEntProp(iClient, Prop_Send, "m_isGhost"));
}
