#include "hotspot_logic/editor_label.as"
#include "hotspot_logic/placeholder.as"

// TODO: Debug log warning spam that sometimes shows up on undo/redo -> [w][__]: scenegraph.cpp: 857: Requested an object with id 3 but found none. Last info known of this id is: 3, Enter Trigger "" Target 1

bool g_is_initializing = true;

string g_main_editor_label_value;
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
    if(main_editor_label_param != g_main_editor_label_value) {
        g_main_editor_label_value = main_editor_label_param;
        ResetPlaceholderArrayEditorDisplayNames(g_target_placeholders, GetTargetPlaceholderLabelName(main_editor_label_param));
    }

    params.AddInt("Target Count", 1);
    int target_placeholder_count = max(params.GetInt("Target Count"), 0);
    params.SetInt("Target Count", target_placeholder_count);
    if(target_placeholder_count != int(GetPlaceholderArrayCount(g_target_placeholders))) {
        SyncPlaceholderArrayInstances(
            g_target_placeholders, params, hotspot_obj, target_placeholder_count, "On-Enter", GetTargetPlaceholderLabelName(main_editor_label_param));
    }

    ProtectPlaceholderArrayParams(g_target_placeholders, params);
}

void HandleEvent(string event, MovementObject @mo) {
    if(event == "enter") {
        Log(info, "------- Enter Trigger Fired: " + params.GetString("Editor Label"));
        Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
        SendScriptMessageToPlaceholderArrayTargets(g_target_placeholders, hotspot_obj);
    }
}

void Update() {
    if(g_is_initializing) {
        g_is_initializing = false;
        LoadFromParams();
    }

    if(EditorModeActive()) {
        Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
        UpdatePlaceholderArrayTransforms(g_target_placeholders, hotspot_obj);
        DrawPlaceholderArrayIcon(g_target_placeholders, DrawLightningBoltIcon, vec4(1.0f, 1.0f, 0.0f, 1.0f), kDeleteOnUpdateDrawLifetime);
        DebugDrawText(hotspot_obj.GetTranslation(), GetMainEditorLabel(g_main_editor_label_value), 1.0f, false, _delete_on_update);            

        if(hotspot_obj.IsSelected() || IsAnyPlaceholderArrayItemSelected(g_target_placeholders)) {
            ResetPlaceholderArrayEditorLabel(g_target_placeholders, "On-Enter");
        } else {
            ResetPlaceholderArrayEditorLabel(g_target_placeholders, "");
        }
    }
}

void ReceiveMessage(string message) {
    if(message == "hotspot_logic_log_state") {
        LogPlaceholderArrayState(g_target_placeholders, ReadObjectFromID(hotspot.GetID()));
    } else if (message == "hotspot_logic_notify_deleted") {
        // Intentionally not deleting placeholder array in Dispose.
        //
        // If we call QueueDeleteObjectID in Dispose, it messes up undo/redo state.
        // If we call DeleteObjectID in Dipose, the level crashes on exit, either due to double delete,
        //   or due to calling Dispose on deleted objects (not sure which)
        DisposePlaceholderArray(g_target_placeholders);
    }
}

void LoadFromParams() {
    string editor_label = params.HasParam("Editor Label") ? params.GetString("Editor Label") : "";

    DisposePlaceholderArray(g_target_placeholders);
    g_target_placeholders = CreatePlaceholderArray(params, "_target_placeholder_ids", "On-Enter", GetTargetPlaceholderLabelName(editor_label));

    SetParameters();
}

string GetMainEditorLabel(string label_value) {
    return "Enter Trigger" +
        (label_value != ""
            ? ": " + label_value
            : "");
}

string GetTargetPlaceholderLabelName(string main_editor_label) {
    return "Enter Trigger" + " \"" + main_editor_label + "\" " + "Target";
}
