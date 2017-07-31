enum DrawLifetime {
    // TODO: Can we somehow get these from the constants? Seems to be giving me negative values
    //       In the mean time, have to be careful to keep them up to date
    kDeleteOnDrawDrawLifetime = 0,  // _delete_on_draw
    kDeleteOnUpdateDrawLifetime = 1,  // _delete_on_update
    kFadeDrawLifetime = 2,  // _fade
    kPersistentDrawLifetime = 3,  // _persistent
};

funcdef int DRAW_ICON_CALLBACK(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime);

int DrawDiskIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] disk_icon_lines = {
        // Body
        vec3(-1.0f, 1.0f, 0.0f), vec3(1.0f, 1.0f, 0.0f),    // Top
        vec3(-1.0f, -1.0f, 0.0f), vec3(1.0f, -1.0f, 0.0f),  // Bottom
        vec3(-1.0f, 1.0f, 0.0f), vec3(-1.0f, -1.0f, 0.0f),  // Left
        vec3(1.0f, 1.0f, 0.0f), vec3(1.0f, -1.0f, 0.0f),    // Right

        // Read shield
        vec3(-0.6f, 1.0f, 0.0f), vec3(-0.6f, 0.2f, 0.0f),  // Left
        vec3(-0.6f, 0.2f, 0.0f), vec3(0.6f, 0.2f, 0.0f),   // Bottom
        vec3(0.6f, 0.2f, 0.0f), vec3(0.6f, 1.0f, 0.0f),    // Right

        // Read slot
        vec3(0.2f, 0.8f, 0.0f), vec3(0.4f, 0.8f, 0.0f),  // Top
        vec3(0.2f, 0.4f, 0.0f), vec3(0.4f, 0.4f, 0.0f),  // Bottom
        vec3(0.2f, 0.8f, 0.0f), vec3(0.2f, 0.4f, 0.0f),  // Left
        vec3(0.4f, 0.8f, 0.0f), vec3(0.4f, 0.4f, 0.0f),  // Right

        // Read shield
        vec3(-0.8f, -1.0f, 0.0f), vec3(-0.8f, 0.0f, 0.0f),  // Left
        vec3(-0.8f, 0.0f, 0.0f), vec3(0.8f, 0.0f, 0.0f),    // Top
        vec3(0.8f, 0.0f, 0.0f), vec3(0.8f, -1.0f, 0.0f),    // Right
    };

    for(uint i = 0, len = disk_icon_lines.length(); i < len; i++) {
        disk_icon_lines[i] = transform * disk_icon_lines[i];
    }

    return DebugDrawLines(disk_icon_lines, color, int(lifetime));
}

int DrawPlayIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] play_icon_lines = {
        vec3(-1.0f, 1.0f, 0.0f), vec3(1.0f, 0.0f, 0.0f),    // Top
        vec3(-1.0f, -1.0f, 0.0f), vec3(1.0f, 0.0f, 0.0f),  // Bottom
        vec3(-1.0f, 1.0f, 0.0f), vec3(-1.0f, -1.0f, 0.0f),  // Left
    };

    for(uint i = 0, len = play_icon_lines.length(); i < len; i++) {
        play_icon_lines[i] = transform * play_icon_lines[i];
    }

    return DebugDrawLines(play_icon_lines, color, int(lifetime));
}

int DrawFlagIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] flag_icon_lines = {
        vec3(-0.6f, 1.0f, 0.0f), vec3(0.6f, 0.5f, 0.0f),    // Top
        vec3(-0.6f, 0.0f, 0.0f), vec3(0.6f, 0.5f, 0.0f),  // Bottom

        vec3(-0.7f, 1.0f, 0.0f), vec3(-0.6f, 1.0f, 0.0f),  // Pole Top
        vec3(-0.7f, -1.0f, 0.0f), vec3(-0.6f, -1.0f, 0.0f),  // Pole Bottom
        vec3(-0.7f, 1.0f, 0.0f), vec3(-0.7f, -1.0f, 0.0f),  // Pole Left
        vec3(-0.6f, 1.0f, 0.0f), vec3(-0.6f, -1.0f, 0.0f),  // Pole Right
    };

    for(uint i = 0, len = flag_icon_lines.length(); i < len; i++) {
        flag_icon_lines[i] = transform * flag_icon_lines[i];
    }

    return DebugDrawLines(flag_icon_lines, color, int(lifetime));
}

int DrawRabbitTeleportIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] rabbit_teleport_icon_lines = {
        // Rabbit head
        vec3(-0.25, 1.0f, 0.0f), vec3(0.25f, 0.5f, 0.0f),    // Top ear to back of head
        vec3(-0.375, 0.75f, 0.0f), vec3(0.0f, 0.75f, 0.0f),  // Bototm ear
        vec3(0.0f, 0.75f, 0.0f), vec3(-0.25f, 0.5f, 0.0f),   // Forehead
        vec3(-0.25f, 0.5f, 0.0f), vec3(0.0f, 0.25f, 0.0f),   // Chin
        vec3(0.0f, 0.25f, 0.0f), vec3(0.25f, 0.5f, 0.0f),    // Bottom of head

        // Rabbit eye
        vec3(-0.09375f, 0.5f, 0.0f), vec3(0.0f, 0.59375, 0.0f),  // Top left
        vec3(0.0f, 0.59375, 0.0f), vec3(0.09375f, 0.5f, 0.0f),   // Top right
        vec3(-0.09375f, 0.5f, 0.0f), vec3(0.0f, 0.40625, 0.0f),   // Bottom left
        vec3(0.0f, 0.40625, 0.0f), vec3(0.09375f, 0.5f, 0.0f),    // Bottom right

        // Arrow
        vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, -0.5f, 0.0f),        // Line
        vec3(0.0f, -0.5f, 0.0f), vec3(-0.125f, -0.375f, 0.0f),  // Left serif
        vec3(0.0f, -0.5f, 0.0f), vec3(0.125f, -0.375f, 0.0f),   // Right serif

        // Target
        vec3(0.0f, -1.0f, 0.0f), vec3(-0.5f, -0.875f, 0.0f),    // Left Bottom
        vec3(-0.5f, -0.875f, 0.0f), vec3(-0.75, -0.625, 0.0f),  // Left Bottom 2
        vec3(-0.75, -0.625, 0.0f), vec3(-0.625, -0.5, 0.0f),    // Left Top
        vec3(0.0f, -1.0f, 0.0f), vec3(0.5f, -0.875f, 0.0f),   // Right Bottom
        vec3(0.5f, -0.875f, 0.0f), vec3(0.75, -0.625, 0.0f),  // Right Bottom 2
        vec3(0.75, -0.625, 0.0f), vec3(0.625, -0.5, 0.0f),    // Right Top
    };

    for(uint i = 0, len = rabbit_teleport_icon_lines.length(); i < len; i++) {
        rabbit_teleport_icon_lines[i] = transform * rabbit_teleport_icon_lines[i];
    }

    return DebugDrawLines(rabbit_teleport_icon_lines, color, int(lifetime));
}

int DrawLightningBoltIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] lightning_bolt_icon_lines = {
        vec3(-0.125, 1.0f, 0.0f), vec3(0.3333f, 1.0f, 0.0f),  // Top

        vec3(-0.125f, 1.0f, 0.0f), vec3(-0.3333f, 0.0f, 0.0f),  // Left Top
        vec3(-0.3333f, 0.0f, 0.0f), vec3(0.0f, 0.0f, 0.0f),     // Left Ledge
        vec3(0.0f, 0.0f, 0.0f), vec3(-0.3333f, -1.0f, 0.0f),    // Left Bottom

        vec3(0.3333f, 1.0f, 0.0f), vec3(0.125f, 0.25f, 0.0f),    // Right top
        vec3(0.125f, 0.25f, 0.0f), vec3(0.375f, 0.25f, 0.0f),    // Right ledge
        vec3(0.375f, 0.25f, 0.0f), vec3(-0.3333f, -1.0f, 0.0f),  // Right bottom
    };

    for(uint i = 0, len = lightning_bolt_icon_lines.length(); i < len; i++) {
        lightning_bolt_icon_lines[i] = transform * lightning_bolt_icon_lines[i];
    }

    return DebugDrawLines(lightning_bolt_icon_lines, color, int(lifetime));
}

int DrawPowerPlugIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] power_plug_icon_lines = {
        // Plug body
        vec3(0.0f, 1.0f, 0.0f), vec3(1.0f, 0.0f, 0.0f),              // Face
        vec3(0.0f, 1.0f, 0.0f), vec3(-0.375f, 0.625f, 0.0f),         // Top side
        vec3(-0.375f, 0.6255f, 0.0f), vec3(-0.5f, 0.25f, 0.0f),
        vec3(-0.5f, 0.25f, 0.0f), vec3(-0.375f, -0.125f, 0.0f),
        vec3(1.0f, 0.0f, 0.0f), vec3(0.625f, -0.375f, 0.0f),         // Bottom side
        vec3(0.625f, -0.375f, 0.0f), vec3(0.25f, -0.5f, 0.0f),
        vec3(0.25f, -0.5f, 0.0f), vec3(-0.125f, -0.375f, 0.0f),
        vec3(-0.375f, -0.125f, 0.0f), vec3(-0.125f, -0.375f, 0.0f),  // Back

        // Prongs
        vec3(0.3333f, 0.6667f, 0.0f), vec3(0.6667f, 1.0f, 0.0f),  // Top
        vec3(0.6667f, 0.3333f, 0.0f), vec3(1.0f, 0.6667f, 0.0f),  // Bottom

        // Cord
        vec3(-0.25f, -0.25f, 0.0f), vec3(-0.625f, -0.625f, 0.0f),
        vec3(-0.625f, -0.625f, 0.0f), vec3(-0.625f, -0.875f, 0.0f),
        vec3(-0.625f, -0.875f, 0.0f), vec3(-1.0f, -1.0f, 0.0f),
    };

    for(uint i = 0, len = power_plug_icon_lines.length(); i < len; i++) {
        power_plug_icon_lines[i] = transform * power_plug_icon_lines[i];
    }

    return DebugDrawLines(power_plug_icon_lines, color, int(lifetime));
}

int DrawTargetIcon(const mat4 &in transform, const vec4 &in color, DrawLifetime lifetime) {
    vec3[] target_icon_lines = {
        // Reticle lines
        vec3(0.0f, 1.0f, 0.0f), vec3(0.0f, 0.675f, 0.0f),    // Top
        vec3(0.0f, -1.0f, 0.0f), vec3(0.0f, -0.675f, 0.0f),  // Bottom
        vec3(-1.0f, 0.0f, 0.0f), vec3(-0.675f, 0.0f, 0.0f),  // Left
        vec3(1.0f, 0.0f, 0.0f), vec3(0.675f, 0.0f, 0.0f),    // Right

        // Outer circle

        // # Python to generate:
        // import math
        //
        // scale = 0.875
        // tess = 32
        //
        // def get_sin_angle(i):
        //     return round(math.sin(math.pi * 2 * i / tess) * scale, 4) + 0
        //
        // def get_cos_angle(i):
        //     return round(math.cos(math.pi * 2 * i / tess) * scale, 4) + 0
        //
        // for i in range(tess):
        //     print(
        //         'vec3({0}f, {1}f, 0.0f),'.format(get_sin_angle(i), get_cos_angle(i)),
        //         'vec3({0}f, {1}f, 0.0f),'.format(get_sin_angle(i + 1), get_cos_angle(i + 1)))
        vec3(0.0f, 0.875f, 0.0f), vec3(0.1707f, 0.8582f, 0.0f),
        vec3(0.1707f, 0.8582f, 0.0f), vec3(0.3348f, 0.8084f, 0.0f),
        vec3(0.3348f, 0.8084f, 0.0f), vec3(0.4861f, 0.7275f, 0.0f),
        vec3(0.4861f, 0.7275f, 0.0f), vec3(0.6187f, 0.6187f, 0.0f),
        vec3(0.6187f, 0.6187f, 0.0f), vec3(0.7275f, 0.4861f, 0.0f),
        vec3(0.7275f, 0.4861f, 0.0f), vec3(0.8084f, 0.3348f, 0.0f),
        vec3(0.8084f, 0.3348f, 0.0f), vec3(0.8582f, 0.1707f, 0.0f),
        vec3(0.8582f, 0.1707f, 0.0f), vec3(0.875f, 0.0f, 0.0f),
        vec3(0.875f, 0.0f, 0.0f), vec3(0.8582f, -0.1707f, 0.0f),
        vec3(0.8582f, -0.1707f, 0.0f), vec3(0.8084f, -0.3348f, 0.0f),
        vec3(0.8084f, -0.3348f, 0.0f), vec3(0.7275f, -0.4861f, 0.0f),
        vec3(0.7275f, -0.4861f, 0.0f), vec3(0.6187f, -0.6187f, 0.0f),
        vec3(0.6187f, -0.6187f, 0.0f), vec3(0.4861f, -0.7275f, 0.0f),
        vec3(0.4861f, -0.7275f, 0.0f), vec3(0.3348f, -0.8084f, 0.0f),
        vec3(0.3348f, -0.8084f, 0.0f), vec3(0.1707f, -0.8582f, 0.0f),
        vec3(0.1707f, -0.8582f, 0.0f), vec3(0.0f, -0.875f, 0.0f),
        vec3(0.0f, -0.875f, 0.0f), vec3(-0.1707f, -0.8582f, 0.0f),
        vec3(-0.1707f, -0.8582f, 0.0f), vec3(-0.3348f, -0.8084f, 0.0f),
        vec3(-0.3348f, -0.8084f, 0.0f), vec3(-0.4861f, -0.7275f, 0.0f),
        vec3(-0.4861f, -0.7275f, 0.0f), vec3(-0.6187f, -0.6187f, 0.0f),
        vec3(-0.6187f, -0.6187f, 0.0f), vec3(-0.7275f, -0.4861f, 0.0f),
        vec3(-0.7275f, -0.4861f, 0.0f), vec3(-0.8084f, -0.3348f, 0.0f),
        vec3(-0.8084f, -0.3348f, 0.0f), vec3(-0.8582f, -0.1707f, 0.0f),
        vec3(-0.8582f, -0.1707f, 0.0f), vec3(-0.875f, 0.0f, 0.0f),
        vec3(-0.875f, 0.0f, 0.0f), vec3(-0.8582f, 0.1707f, 0.0f),
        vec3(-0.8582f, 0.1707f, 0.0f), vec3(-0.8084f, 0.3348f, 0.0f),
        vec3(-0.8084f, 0.3348f, 0.0f), vec3(-0.7275f, 0.4861f, 0.0f),
        vec3(-0.7275f, 0.4861f, 0.0f), vec3(-0.6187f, 0.6187f, 0.0f),
        vec3(-0.6187f, 0.6187f, 0.0f), vec3(-0.4861f, 0.7275f, 0.0f),
        vec3(-0.4861f, 0.7275f, 0.0f), vec3(-0.3348f, 0.8084f, 0.0f),
        vec3(-0.3348f, 0.8084f, 0.0f), vec3(-0.1707f, 0.8582f, 0.0f),
        vec3(-0.1707f, 0.8582f, 0.0f), vec3(0.0f, 0.875f, 0.0f),

        // Draw inner reticle
        vec3(0.0f, 0.125f, 0.0f), vec3(-0.125f, 0.0f, 0.0),  // Top left
        vec3(0.0f, 0.125f, 0.0f), vec3(0.125f, 0.0f, 0.0),  // Top right
        vec3(0.0f, -0.125f, 0.0f), vec3(-0.125f, 0.0f, 0.0),  // Bottom left
        vec3(0.0f, -0.125f, 0.0f), vec3(0.125f, 0.0f, 0.0),  // Bottom right
    };

    for(uint i = 0, len = target_icon_lines.length(); i < len; i++) {
        target_icon_lines[i] = transform * target_icon_lines[i];
    }

    return DebugDrawLines(target_icon_lines, color, int(lifetime));
}

mat4 ComposeBillboardTransform(
        const vec3 &in translation, const vec3 &in rotation_normal, const vec3 &in scale,
        const vec3 &in up_direction = vec3(0.0f, 1.0f, 0.0f)) {
    const vec3 right_direction = normalize(cross(rotation_normal, up_direction));
    const vec3 new_up_direction = cross(right_direction, rotation_normal);

    mat4 result_rotation;
    result_rotation.SetColumn(0, vec3(right_direction.x, right_direction.y, right_direction.z));
    result_rotation.SetColumn(1, vec3(new_up_direction.x, new_up_direction.y, new_up_direction.z));
    result_rotation.SetColumn(2, vec3(rotation_normal.x, rotation_normal.y, rotation_normal.z));

    mat4 result_scale;
    result_scale.SetColumn(0, vec3(scale.x, 0.0f, 0.0f));
    result_scale.SetColumn(1, vec3(0.0f, scale.y, 0.0f));
    result_scale.SetColumn(2, vec3(0.0f, 0.0f, scale.z));

    mat4 result_translation;
    result_translation.SetColumn(3, translation);

    return result_translation * result_rotation * result_scale;
}

mat4 ComposeTransform(const vec3 &in translation, const quaternion &in rotation, const vec3 &in scale) {
    mat4 result_rotation = Mat4FromQuaternion(rotation);
    mat4 result_scale;
    result_scale.SetColumn(0, vec3(scale.x, 0.0f, 0.0f));
    result_scale.SetColumn(1, vec3(0.0f, scale.x, 0.0f));
    result_scale.SetColumn(2, vec3(0.0f, 0.0f, scale.z));
    mat4 result_translation;
    result_translation.SetColumn(3, translation);

    return result_translation * result_scale * result_rotation;
}

vec3 ClampToSquareAspectRatio(const vec3 &in value) {
    float min_component = min(min(value.x, value.y), value.z);
    return vec3(min_component, min_component, min_component);
}
