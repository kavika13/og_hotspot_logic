#include "hotspot_logic/editor_label.as"
#include "hotspot_logic/placeholder.as"

// TODO: Debug log warning spam that sometimes shows up on undo/redo -> [w][__]: scenegraph.cpp: 857: Requested an object with id 3 but found none. Last info known of this id is: 3, Enter Trigger "" Target 1

bool g_is_initializing = true;

EditorLabel g_main_editor_label;
Placeholder g_trigger_placeholder;
PlaceholderArray g_target_placeholders;

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
        ResetPlaceholderEditorDisplayName(g_trigger_placeholder, GetTriggerPlaceholderLabelName(main_editor_label_param));
        ResetPlaceholderArrayEditorDisplayNames(g_target_placeholders, GetTargetPlaceholderLabelName(main_editor_label_param));
    }

    params.AddInt("Target Count", 1);
    int target_placeholder_count = max(params.GetInt("Target Count"), 0);
    params.SetInt("Target Count", target_placeholder_count);
    if(target_placeholder_count != int(GetPlaceholderArrayCount(g_target_placeholders))) {
        SyncPlaceholderArrayInstances(
            g_target_placeholders, params, hotspot_obj, target_placeholder_count, "Target", GetTargetPlaceholderLabelName(main_editor_label_param));
    }

    ProtectPlaceholderParams(g_trigger_placeholder, params);
    ProtectPlaceholderArrayParams(g_target_placeholders, params);
}

void Update() {
    if(g_is_initializing) {
        g_is_initializing = false;
        LoadFromParams();
    }

    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
    UpdatePlaceholderParentConnection(g_trigger_placeholder, hotspot_obj);
    // Target points at the dialogue to play, not the parent hotspot

    if(EditorModeActive()) {
        ActivateEditorLabel(g_main_editor_label, hotspot_obj);
        UpdateEditorLabel(g_main_editor_label, hotspot_obj);
        UpdatePlaceholderTransform(g_trigger_placeholder, hotspot_obj);
        UpdatePlaceholderArrayTransforms(g_target_placeholders, hotspot_obj);
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
    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());

    if(token == "hotspot_logic_triggered") {
        if(token_iter.FindNextToken(message)) {
            int input_placeholder_id = atoi(token_iter.GetToken(message));

            if(input_placeholder_id == g_trigger_placeholder.id) {
                Log(info, "------- Activate Target Triggered: " + params.GetString("Editor Label"));

                for(uint i = 0; i < GetPlaceholderArrayCount(g_target_placeholders); i++) {
                    Object@ target_obj = GetPlaceholderArrayTargetAtIndex(g_target_placeholders, i);

                    if(!(target_obj is null) && target_obj.GetType() == _movement_object) {
                        ReadCharacterID(target_obj.GetID()).Execute("static_char = false;");
                    } else {
                        Log(warning, "------- No Target Set to Activate, or target is not Movement Object: " + params.GetString("Editor Label"));
                    }
                }
            }
        }
    } else if(token == "hotspot_logic_log_state") {
        LogPlaceholderState(g_trigger_placeholder, hotspot_obj);
        LogPlaceholderArrayState(g_target_placeholders, hotspot_obj);
    } else if (token == "hotspot_logic_notify_deleted") {
        // Intentionally not deleting placeholders in Dispose.
        //
        // If we call QueueDeleteObjectID in Dispose, it messes up undo/redo state.
        // If we call DeleteObjectID in Dipose, the level crashes on exit, either due to double delete,
        //   or due to calling Dispose on deleted objects (not sure which)
        DisposePlaceholder(g_trigger_placeholder);
        DisposePlaceholderArray(g_target_placeholders);
    }
}

void LoadFromParams() {
    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
    DisposeEditorLabel(g_main_editor_label);

    string editor_label = params.HasParam("Editor Label") ? params.GetString("Editor Label") : "";
    g_main_editor_label = CreateEditorLabel(hotspot_obj, GetMainEditorLabel(editor_label));

    DisposePlaceholder(g_trigger_placeholder);
    g_trigger_placeholder = CreatePlaceholder(
        kHotspotInputTerminalPlaceholder, hotspot_obj, params, "_trigger_placeholder_id",
        "Trigger", GetTriggerPlaceholderLabelName(editor_label), vec3(0.0f, 0.0f, 1.0f));
    UpdatePlaceholderParentConnection(g_trigger_placeholder, hotspot_obj);

    DisposePlaceholderArray(g_target_placeholders);
    g_target_placeholders = CreatePlaceholderArray(
        params, "_target_placeholder_ids",
        "Target", GetTargetPlaceholderLabelName(editor_label), vec3(0.0f, 0.0f, -1.0f));
    EntityType[] allowed_target_types = { _movement_object };
    SetPlaceholderArrayAllowedConnectionTypes(g_target_placeholders, allowed_target_types);

    SetParameters();
}

string GetMainEditorLabel(string label_value) {
    return "Activate Target" +
        (label_value != ""
            ? ": " + label_value
            : "");
}

string GetTriggerPlaceholderLabelName(string main_editor_label) {
    return "Activate Target" + " \"" + main_editor_label + "\" " + "Trigger";
}

string GetTargetPlaceholderLabelName(string main_editor_label) {
    return "Activate Target" + " \"" + main_editor_label + "\" " + "Target";
}
