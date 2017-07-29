#include "hotspot_logic/editor_label.as"
#include "hotspot_logic/placeholder.as"

// TODO: Debug log warning spam that sometimes shows up on undo/redo -> [w][__]: scenegraph.cpp: 857: Requested an object with id 3 but found none. Last info known of this id is: 3, Enter Trigger "" Target 1

bool g_is_initializing = true;
bool g_are_all_targets_defeated = false;
int[] g_defeated_target_ids;

EditorLabel g_main_editor_label;
PlaceholderArray g_target_placeholders;
PlaceholderArray g_on_defeat_placeholders;

string GetTypeString() {
    return "hotspot_logic";
}

void Init() {
    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
    hotspot_obj.SetCopyable(false);
}

void SetParameters() {
    if(g_is_initializing) {
        return;
    }

    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());

    params.AddString("Editor Label", "");
    string main_editor_label_param = params.GetString("Editor Label");
    if(main_editor_label_param != g_main_editor_label.value) {
        SetEditorLabelValue(g_main_editor_label, hotspot_obj, GetMainEditorLabel(main_editor_label_param));
        ResetPlaceholderArrayEditorDisplayNames(g_target_placeholders, GetTargetPlaceholderLabelName(main_editor_label_param));
    }

    params.AddInt("Target Count", 1);
    int target_placeholder_count = max(params.GetInt("Target Count"), 0);
    params.SetInt("Target Count", target_placeholder_count);
    if(target_placeholder_count != int(GetPlaceholderArrayCount(g_target_placeholders))) {
        SyncPlaceholderArrayInstances(
            g_target_placeholders, params, hotspot_obj, target_placeholder_count, "Target", GetTargetPlaceholderLabelName(main_editor_label_param));
        // TODO: Clear out obsolete targets instead?
        Log(info, "------- Defeat Trigger Reset: " + params.GetString("Editor Label"));
        g_are_all_targets_defeated = false;
        g_defeated_target_ids.resize(0);
    }

    params.AddInt("On-Defeat Count", 1);
    int on_defeat_placeholder_count = max(params.GetInt("On-Defeat Count"), 0);
    params.SetInt("On-Defeat Count", on_defeat_placeholder_count);
    if(on_defeat_placeholder_count != int(GetPlaceholderArrayCount(g_on_defeat_placeholders))) {
        SyncPlaceholderArrayInstances(
            g_on_defeat_placeholders, params, hotspot_obj, on_defeat_placeholder_count, "On-Defeat", GetOnDefeatPlaceholderLabelName(main_editor_label_param));
    }

    ProtectPlaceholderArrayParams(g_target_placeholders, params);
    ProtectPlaceholderArrayParams(g_on_defeat_placeholders, params);
}

void Update() {
    if(g_is_initializing) {
        g_is_initializing = false;
        LoadFromParams();
    }

    if(EditorModeActive()) {
        Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
        ActivateEditorLabel(g_main_editor_label, hotspot_obj);
        UpdateEditorLabel(g_main_editor_label, hotspot_obj);
        UpdatePlaceholderArrayTransforms(g_target_placeholders, hotspot_obj);
        UpdatePlaceholderArrayTransforms(g_on_defeat_placeholders, hotspot_obj);
    } else {
        DeactivateEditorLabel(g_main_editor_label);
    }
}

void Dispose() {
    DisposeEditorLabel(g_main_editor_label);
}

void ReceiveMessage(string message) {
    TokenIterator token_iter;
    token_iter.Init();

    if(!token_iter.FindNextToken(message)) {
        return;
    }

    string token = token_iter.GetToken(message);

    if(token == "reset") {
        Log(info, "------- Defeat Trigger Reset: " + params.GetString("Editor Label"));
        g_are_all_targets_defeated = false;
        g_defeated_target_ids.resize(0);
    } else if(token == "hotspot_logic_character_knocked_out" || token == "hotspot_logic_character_died") {
        if(!g_are_all_targets_defeated && token_iter.FindNextToken(message)) {
            int character_id = atoi(token_iter.GetToken(message));
            uint target_count = GetPlaceholderArrayCount(g_target_placeholders);

            for(uint i = 0; i < target_count; i++) {
                if(GetPlaceholderArrayTargetAtIndex(g_target_placeholders, i).GetID() == character_id && g_defeated_target_ids.find(character_id) < 0) {
                    g_defeated_target_ids.insertLast(character_id);
                    break;
                }
            }

            if(g_defeated_target_ids.length() == target_count) {
                g_are_all_targets_defeated = true;
                Log(info, "------- Defeat Trigger Fired: " + params.GetString("Editor Label"));
                Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
                SendScriptMessageToPlaceholderArrayTargets(g_on_defeat_placeholders, hotspot_obj);
            }
        }
    } else if(token == "hotspot_logic_log_state") {
        Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
        LogPlaceholderArrayState(g_target_placeholders, hotspot_obj);
        LogPlaceholderArrayState(g_on_defeat_placeholders, hotspot_obj);
    } else if (token == "hotspot_logic_notify_deleted") {
        // Intentionally not deleting placeholder array in Dispose.
        //
        // If we call QueueDeleteObjectID in Dispose, it messes up undo/redo state.
        // If we call DeleteObjectID in Dipose, the level crashes on exit, either due to double delete,
        //   or due to calling Dispose on deleted objects (not sure which)
        DisposePlaceholderArray(g_target_placeholders);
        DisposePlaceholderArray(g_on_defeat_placeholders);
    }
}

void LoadFromParams() {
    DisposeEditorLabel(g_main_editor_label);

    string editor_label = params.HasParam("Editor Label") ? params.GetString("Editor Label") : "";
    g_main_editor_label = CreateEditorLabel(ReadObjectFromID(hotspot.GetID()), GetMainEditorLabel(editor_label));

    DisposePlaceholderArray(g_target_placeholders);
    g_target_placeholders = CreatePlaceholderArray(
        params, "_target_placeholder_ids",
        "Target", GetTargetPlaceholderLabelName(editor_label), vec3(0.0f, 0.0f, 1.0f));
    EntityType[] allowed_target_types = { _movement_object };
    SetPlaceholderArrayAllowedConnectionTypes(g_target_placeholders, allowed_target_types);

    DisposePlaceholderArray(g_on_defeat_placeholders);
    g_on_defeat_placeholders = CreatePlaceholderArray(
        params, "_on_defeat_placeholder_ids",
        "On-Defeat", GetOnDefeatPlaceholderLabelName(editor_label), vec3(0.0f, 0.0f, -1.0f));

    SetParameters();
}

string GetMainEditorLabel(string label_value) {
    return "Defeat Trigger" +
        (label_value != ""
            ? ": " + label_value
            : "");
}

string GetTargetPlaceholderLabelName(string main_editor_label) {
    return "Defeat Trigger" + " \"" + main_editor_label + "\" " + "Target";
}

string GetOnDefeatPlaceholderLabelName(string main_editor_label) {
    return "Defeat Trigger" + " \"" + main_editor_label + "\" " + "On-Defeat";
}
