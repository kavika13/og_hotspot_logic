#include "hotspot_logic/editor_label.as"
#include "hotspot_logic/placeholder.as"
#include "hotspot_logic/draw_icon_lines.as"

// TODO: Debug log warning spam that sometimes shows up on undo/redo -> [w][__]: scenegraph.cpp: 857: Requested an object with id 3 but found none. Last info known of this id is: 3, Enter Trigger "" Target 1

bool g_is_initializing = true;

EditorLabel g_main_editor_label;
Placeholder g_trigger_placeholder;
Placeholder g_target_placeholder;

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
        ResetPlaceholderEditorDisplayName(g_target_placeholder, GetTargetPlaceholderLabelName(main_editor_label_param));
    }

    ProtectPlaceholderParams(g_trigger_placeholder, params);
    ProtectPlaceholderParams(g_target_placeholder, params);
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
        UpdatePlaceholderTransform(g_target_placeholder, hotspot_obj);

        mat4 billboard_transform = GetBillboardTransform(
            hotspot_obj.GetTranslation(), camera.GetFacing(), hotspot_obj.GetScale(), camera.GetUpVector());
        DrawPlayIcon(billboard_transform, vec4(0.0f, 1.0f, 0.0f, 0.5f), kDeleteOnUpdateDrawLifetime);
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
                Log(info, "------- Play Dialogue Triggered: " + params.GetString("Editor Label"));
                Object@ target_obj = GetPlaceholderTarget(g_target_placeholder);
                ScriptParams@ params = target_obj is null ? null : target_obj.GetScriptParams();

                if(!(target_obj is null) && target_obj.GetType() == _placeholder_object && params.HasParam("Dialogue") && params.HasParam("DisplayName")) {
                    level.SendMessage("hotspot_logic_queue_dialogue \"" + params.GetString("DisplayName") + "\"");
                } else {
                    Log(warning, "------- No Dialogue Target Set: " + params.GetString("Editor Label"));
                }
            }
        }
    } else if(token == "hotspot_logic_log_state") {
        LogPlaceholderState(g_trigger_placeholder, hotspot_obj);
        LogPlaceholderState(g_target_placeholder, hotspot_obj);
    } else if (token == "hotspot_logic_notify_deleted") {
        // Intentionally not deleting placeholders in Dispose.
        //
        // If we call QueueDeleteObjectID in Dispose, it messes up undo/redo state.
        // If we call DeleteObjectID in Dipose, the level crashes on exit, either due to double delete,
        //   or due to calling Dispose on deleted objects (not sure which)
        DisposePlaceholder(g_trigger_placeholder);
        DisposePlaceholder(g_target_placeholder);
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

    DisposePlaceholder(g_target_placeholder);
    g_target_placeholder = CreatePlaceholder(
        kGenericTerminalPlaceholder, hotspot_obj, params, "_target_placeholder_id",
        "Target", GetTargetPlaceholderLabelName(editor_label), vec3(0.0f, 0.0f, -1.0f));
    EntityType[] allowed_target_types = { _placeholder_object };
    SetPlaceholderAllowedConnectionTypes(g_target_placeholder, allowed_target_types);

    SetParameters();
}

string GetMainEditorLabel(string label_value) {
    return "Play Dialogue" +
        (label_value != ""
            ? ": " + label_value
            : "");
}

string GetTriggerPlaceholderLabelName(string main_editor_label) {
    return "Play Dialogue" + " \"" + main_editor_label + "\" " + "Trigger";
}

string GetTargetPlaceholderLabelName(string main_editor_label) {
    return "Play Dialogue" + " \"" + main_editor_label + "\" " + "Target";
}
