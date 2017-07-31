#include "hotspot_logic/placeholder.as"

// TODO: Debug log warning spam that sometimes shows up on undo/redo -> [w][__]: scenegraph.cpp: 857: Requested an object with id 3 but found none. Last info known of this id is: 3, Enter Trigger "" Target 1

bool g_is_initializing = true;
bool g_is_enabled = false;
bool g_is_achieved = false;

string g_main_editor_label_value;
Placeholder g_enable_placeholder;
Placeholder g_achieve_placeholder;
PlaceholderArray g_on_enable_placeholders;
PlaceholderArray g_on_reset_placeholders;
PlaceholderArray g_on_achieve_placeholders;

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
        ResetPlaceholderEditorDisplayName(g_enable_placeholder, GetEnablePlaceholderLabelName(main_editor_label_param));
        ResetPlaceholderEditorDisplayName(g_achieve_placeholder, GetAchievePlaceholderLabelName(main_editor_label_param));
        ResetPlaceholderArrayEditorDisplayNames(g_on_enable_placeholders, GetOnEnablePlaceholderLabelName(main_editor_label_param));
        ResetPlaceholderArrayEditorDisplayNames(g_on_reset_placeholders, GetOnResetPlaceholderLabelName(main_editor_label_param));
        ResetPlaceholderArrayEditorDisplayNames(g_on_achieve_placeholders, GetOnAchievePlaceholderLabelName(main_editor_label_param));
    }

    params.AddInt("On-Enable Count", 1);
    int on_enable_placeholder_count = max(params.GetInt("On-Enable Count"), 0);
    params.SetInt("On-Enable Count", on_enable_placeholder_count);
    if(on_enable_placeholder_count != int(GetPlaceholderArrayCount(g_on_enable_placeholders))) {
        SyncPlaceholderArrayInstances(
            g_on_enable_placeholders, params, hotspot_obj, on_enable_placeholder_count, "On-Enable", GetOnEnablePlaceholderLabelName(main_editor_label_param));
    }

    params.AddInt("On-Reset Count", 1);
    int on_reset_placeholder_count = max(params.GetInt("On-Reset Count"), 0);
    params.SetInt("On-Reset Count", on_reset_placeholder_count);
    if(on_reset_placeholder_count != int(GetPlaceholderArrayCount(g_on_reset_placeholders))) {
        SyncPlaceholderArrayInstances(
            g_on_reset_placeholders, params, hotspot_obj, on_reset_placeholder_count, "On-Reset",GetOnResetPlaceholderLabelName(main_editor_label_param));
    }

    params.AddInt("On-Achieve Count", 1);
    int on_achieve_placeholder_count = max(params.GetInt("On-Achieve Count"), 0);
    params.SetInt("On-Achieve Count", on_achieve_placeholder_count);
    if(on_achieve_placeholder_count != int(GetPlaceholderArrayCount(g_on_achieve_placeholders))) {
        SyncPlaceholderArrayInstances(
            g_on_achieve_placeholders, params, hotspot_obj, on_achieve_placeholder_count, "On-Achieve",GetOnAchievePlaceholderLabelName(main_editor_label_param));
    }

    ProtectPlaceholderParams(g_enable_placeholder, params);
    ProtectPlaceholderParams(g_achieve_placeholder, params);
    ProtectPlaceholderArrayParams(g_on_enable_placeholders, params);
    ProtectPlaceholderArrayParams(g_on_reset_placeholders, params);
    ProtectPlaceholderArrayParams(g_on_achieve_placeholders, params);
}

void Update() {
    if(g_is_initializing) {
        g_is_initializing = false;
        LoadFromParams();
    }

    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());
    UpdatePlaceholderParentConnection(g_enable_placeholder, hotspot_obj);
    UpdatePlaceholderParentConnection(g_achieve_placeholder, hotspot_obj);

    if(EditorModeActive()) {
        UpdatePlaceholderTransform(g_enable_placeholder, hotspot_obj);
        UpdatePlaceholderTransform(g_achieve_placeholder, hotspot_obj);
        UpdatePlaceholderArrayTransforms(g_on_enable_placeholders, hotspot_obj);
        UpdatePlaceholderArrayTransforms(g_on_reset_placeholders, hotspot_obj);
        UpdatePlaceholderArrayTransforms(g_on_achieve_placeholders, hotspot_obj);

        vec3 hotspot_square_scale = ClampToSquareAspectRatio(hotspot_obj.GetScale());
        mat4 billboard_transform = ComposeBillboardTransform(
            hotspot_obj.GetTranslation(), camera.GetFacing(), hotspot_square_scale, camera.GetUpVector());
        DrawPlaceholderIcon(g_enable_placeholder, DrawPowerIcon, vec4(0.0f, 1.0f, 1.0f, 1.0f), kDeleteOnUpdateDrawLifetime);
        DrawPlaceholderIcon(g_achieve_placeholder, DrawFlagIcon, vec4(0.0f, 1.0f, 1.0f, 1.0f), kDeleteOnUpdateDrawLifetime);
        DrawPlaceholderArrayIcon(g_on_enable_placeholders, DrawPowerIcon, vec4(1.0f, 1.0f, 0.0f, 1.0f), kDeleteOnUpdateDrawLifetime);
        DrawPlaceholderArrayIcon(g_on_reset_placeholders, DrawPowerIcon, vec4(1.0f, 0.5f, 0.0f, 1.0f), kDeleteOnUpdateDrawLifetime);  // TODO: Reset/recycle icon
        DrawPlaceholderArrayIcon(g_on_achieve_placeholders, DrawFlagIcon, vec4(0.0f, 1.0f, 0.0f, 1.0f), kDeleteOnUpdateDrawLifetime);
        DrawFlagIcon(billboard_transform, vec4(0.0f, 1.0f, 0.0f, 1.0f), kDeleteOnUpdateDrawLifetime);
        DebugDrawText(hotspot_obj.GetTranslation(), GetMainEditorLabel(g_main_editor_label_value), 1.0f, false, _delete_on_update);            

        if(hotspot_obj.IsSelected() ||
                IsPlaceholderSelected(g_enable_placeholder) ||
                IsPlaceholderSelected(g_achieve_placeholder) ||
                IsAnyPlaceholderArrayItemSelected(g_on_enable_placeholders) ||
                IsAnyPlaceholderArrayItemSelected(g_on_reset_placeholders) ||
                IsAnyPlaceholderArrayItemSelected(g_on_achieve_placeholders)) {
            ResetPlaceholderEditorLabel(g_enable_placeholder, "Enable");
            ResetPlaceholderEditorLabel(g_achieve_placeholder, "Achieve");
            ResetPlaceholderArrayEditorLabel(g_on_enable_placeholders, "On-Enable");
            ResetPlaceholderArrayEditorLabel(g_on_reset_placeholders, "On-Reset");
            ResetPlaceholderArrayEditorLabel(g_on_achieve_placeholders, "On-Achieve");
        } else {
            ResetPlaceholderEditorLabel(g_enable_placeholder, "");
            ResetPlaceholderEditorLabel(g_achieve_placeholder, "");
            ResetPlaceholderArrayEditorLabel(g_on_enable_placeholders, "");
            ResetPlaceholderArrayEditorLabel(g_on_reset_placeholders, "");
            ResetPlaceholderArrayEditorLabel(g_on_achieve_placeholders, "");
        }
    }
}

void ReceiveMessage(string message) {
    TokenIterator token_iter;
    token_iter.Init();

    if(!token_iter.FindNextToken(message)) {
        return;
    }

    string token = token_iter.GetToken(message);
    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());

    if(token == "reset") {
        if(g_is_enabled && !g_is_achieved) {
            Log(info, "------- Goal Reset: " + params.GetString("Editor Label"));

            SendScriptMessageToPlaceholderArrayTargets(g_on_reset_placeholders, hotspot_obj);
        }
    } else if(token == "hotspot_logic_triggered") {
        if(token_iter.FindNextToken(message)) {
            int input_placeholder_id = atoi(token_iter.GetToken(message));

            if(!g_is_enabled && input_placeholder_id == g_enable_placeholder.id) {
                Log(info, "------- Goal Enabled: " + params.GetString("Editor Label"));

                g_is_enabled = true;
                g_is_achieved = false;

                SendScriptMessageToPlaceholderArrayTargets(g_on_enable_placeholders, hotspot_obj);
            } else if(g_is_enabled && !g_is_achieved && input_placeholder_id == g_achieve_placeholder.id) {
                Log(info, "------- Goal Achieved: " + params.GetString("Editor Label"));

                g_is_achieved = true;
                g_is_enabled = false;

                SendScriptMessageToPlaceholderArrayTargets(g_on_achieve_placeholders, hotspot_obj);
            }
        }
    } else if(token == "hotspot_logic_log_state") {
        LogPlaceholderState(g_enable_placeholder, hotspot_obj);
        LogPlaceholderState(g_achieve_placeholder, hotspot_obj);
        LogPlaceholderArrayState(g_on_enable_placeholders, hotspot_obj);
        LogPlaceholderArrayState(g_on_reset_placeholders, hotspot_obj);
        LogPlaceholderArrayState(g_on_achieve_placeholders, hotspot_obj);
    } else if (token == "hotspot_logic_notify_deleted") {
        // Intentionally not deleting placeholders in Dispose.
        //
        // If we call QueueDeleteObjectID in Dispose, it messes up undo/redo state.
        // If we call DeleteObjectID in Dipose, the level crashes on exit, either due to double delete,
        //   or due to calling Dispose on deleted objects (not sure which)
        DisposePlaceholder(g_enable_placeholder);
        DisposePlaceholder(g_achieve_placeholder);
        DisposePlaceholderArray(g_on_enable_placeholders);
        DisposePlaceholderArray(g_on_reset_placeholders);
        DisposePlaceholderArray(g_on_achieve_placeholders);
    }
}

void LoadFromParams() {
    Object@ hotspot_obj = ReadObjectFromID(hotspot.GetID());

    string editor_label = params.HasParam("Editor Label") ? params.GetString("Editor Label") : "";

    DisposePlaceholder(g_enable_placeholder);
    g_enable_placeholder = CreatePlaceholder(
        kHotspotInputTerminalPlaceholder, hotspot_obj, params, "_enable_placeholder_id",
        "Enable", GetEnablePlaceholderLabelName(editor_label), vec3(-1.0f, 0.0f, 1.0f));
    UpdatePlaceholderParentConnection(g_enable_placeholder, hotspot_obj);

    DisposePlaceholder(g_achieve_placeholder);
    g_achieve_placeholder = CreatePlaceholder(
        kHotspotInputTerminalPlaceholder, hotspot_obj, params, "_achieve_placeholder_id",
        "Achieve", GetAchievePlaceholderLabelName(editor_label), vec3(1.0f, 0.0f, 1.0f));
    UpdatePlaceholderParentConnection(g_achieve_placeholder, hotspot_obj);

    DisposePlaceholderArray(g_on_enable_placeholders);
    g_on_enable_placeholders = CreatePlaceholderArray(
        params, "_on_enable_placeholder_ids",
        "On-Enable", GetOnEnablePlaceholderLabelName(editor_label), vec3(-1.0f, 0.0f, -1.0f), kVerticalPlaceholderArrayLayout);

    DisposePlaceholderArray(g_on_reset_placeholders);
    g_on_reset_placeholders = CreatePlaceholderArray(
        params, "_on_reset_placeholder_ids",
        "On-Reset", GetOnResetPlaceholderLabelName(editor_label), vec3(0.0f, 0.0f, -1.0f), kVerticalPlaceholderArrayLayout);

    DisposePlaceholderArray(g_on_achieve_placeholders);
    g_on_achieve_placeholders = CreatePlaceholderArray(
        params, "_on_achieve_placeholder_ids",
        "On-Achieve", GetOnAchievePlaceholderLabelName(editor_label), vec3(1.0f, 0.0f, -1.0f), kVerticalPlaceholderArrayLayout);

    SetParameters();
}

string GetMainEditorLabel(string label_value) {
    return "Goal" +
        (label_value != ""
            ? ": " + label_value
            : "");
}

string GetEnablePlaceholderLabelName(string main_editor_label) {
    return "Goal" + " \"" + main_editor_label + "\" " + "Enable";
}

string GetAchievePlaceholderLabelName(string main_editor_label) {
    return "Goal" + " \"" + main_editor_label + "\" " + "Achieve";
}

string GetOnEnablePlaceholderLabelName(string main_editor_label) {
    return "Goal" + " \"" + main_editor_label + "\" " + "On-Enable";
}

string GetOnResetPlaceholderLabelName(string main_editor_label) {
    return "Goal" + " \"" + main_editor_label + "\" " + "On-Reset";
}

string GetOnAchievePlaceholderLabelName(string main_editor_label) {
    return "Goal" + " \"" + main_editor_label + "\" " + "On-Achieve";
}
