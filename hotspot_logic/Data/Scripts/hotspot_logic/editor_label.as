class EditorLabel {
    string value = "";
    int debug_draw_id = -1;
    vec3 offset = vec3(0);
};

EditorLabel CreateEditorLabel(Object@ owner, string value, vec3 offset = vec3(0)) {
    EditorLabel result;
    result.value = value;
    result.offset = offset;
    ActivateEditorLabel(result, owner);
    return result;
}

void ActivateEditorLabel(EditorLabel@ editor_label, Object@ owner) {
    if(editor_label.debug_draw_id == -1) {
        editor_label.debug_draw_id = DebugDrawText(owner.GetTranslation(), editor_label.value, 1.0f, false, _persistent);
    }
}

void DeactivateEditorLabel(EditorLabel@ editor_label) {
    if(editor_label.debug_draw_id != -1) {
        DebugDrawRemove(editor_label.debug_draw_id);
        editor_label.debug_draw_id = -1;
    }
}

void SetEditorLabelValue(EditorLabel@ editor_label, Object@ owner, string new_value) {
    DeactivateEditorLabel(editor_label);
    editor_label.value = new_value;
    ActivateEditorLabel(editor_label, owner);
    UpdateEditorLabel(editor_label, owner);
}

void UpdateEditorLabel(EditorLabel@ editor_label, Object@ owner) {
    if(editor_label.debug_draw_id != -1) {
        DebugSetPosition(
            editor_label.debug_draw_id,
            owner.GetTranslation() +
                2.0f *
                vec3(
                    editor_label.offset.x * owner.GetScale().x,
                    editor_label.offset.y * owner.GetScale().y,
                    editor_label.offset.z * owner.GetScale().z));
    }
}

void DisposeEditorLabel(EditorLabel@ editor_label) {
    DeactivateEditorLabel(editor_label);
    editor_label.value = "";
    editor_label.offset = vec3(0);
}
