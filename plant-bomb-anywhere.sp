#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clients>

#define PLUGIN_VERSION "1.0" 
#pragma semicolon 1
#pragma newdecls required

ConVar sm_plant_bomb_anywhere_enabled, sm_plant_bomb_automatic_give_new_bomb;

public Plugin myinfo =
{
	name = "[CS:GO] Plant bomb anywhere",
	author = "IT-KiLLER",
	description = "Plant bomb anywhere in the map.",
	version = PLUGIN_VERSION,
	url = "https://github.com/it-killer"
}

public void OnPluginStart()
{
	HookEvent("bomb_planted", Event_BombPlant, EventHookMode_Post);
	CreateConVar("sm_plant_bomb_anywhere_version", PLUGIN_VERSION, "Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	sm_plant_bomb_anywhere_enabled  = CreateConVar("sm_plant_bomb_anywhere_enabled", "1", "Enabled or disabled", _, true, 0.0, true, 1.0); 
	sm_plant_bomb_automatic_give_new_bomb  = CreateConVar("sm_plant_bomb_anywhere_unlimted", "1", "Unlimited number of bombs", _, true, 0.0, true, 1.0); 
	HookConVarChange(sm_plant_bomb_anywhere_enabled, OnConVarChange);
	for(int client = 1; client <= MaxClients; client++) {
		if(IsClientInGame(client)) {
			OnClientPutInServer(client);
		}
	}
}

public void OnClientPutInServer(int client) 
{ 
	if(!sm_plant_bomb_anywhere_enabled.BoolValue) return;
	SDKHook(client, SDKHook_PostThink, OnPostThink);
} 

public void OnClientDisconnect(int client)
{
	if(!sm_plant_bomb_anywhere_enabled.BoolValue && !IsClientInGame(client)) return;
	SDKUnhook(client, SDKHook_PostThink, OnPostThink);
}

public void OnConVarChange(Handle hCvar, const char[] oldValue, const char[] newValue)
{
	if (StrEqual(oldValue, newValue)) return;
	if (hCvar == sm_plant_bomb_anywhere_enabled)
		if(GetConVarBool(sm_plant_bomb_anywhere_enabled)){
			for(int client = 1; client <= MaxClients; client++) 
				if(IsClientInGame(client)) SDKHook(client, SDKHook_PostThink, OnPostThink);
		} else {
			for(int client = 1; client <= MaxClients; client++) 
				if(IsClientInGame(client)) SDKUnhook(client, SDKHook_PostThink, OnPostThink);
		}

}

public void OnPostThink(int client)
{	
	if(!sm_plant_bomb_anywhere_enabled.BoolValue) return;
	SetEntProp(client, Prop_Send, "m_bInBombZone", 1);
	GameRules_SetProp("m_bBombPlanted", 0, true);
}  

public Action Event_BombPlant(Handle event, const char[] name, bool dontBroadcast) {
	if(sm_plant_bomb_anywhere_enabled.BoolValue && sm_plant_bomb_automatic_give_new_bomb.BoolValue) 
		GivePlayerItem(GetClientOfUserId(GetEventInt(event,"userid")), "weapon_c4");
	return Plugin_Continue;
}
