def build_personalized_script(onboarding: dict) -> dict:
    intentions = [x.lower() for x in onboarding.get("intentions", [])]
    moods = [x.lower() for x in onboarding.get("moods", [])]
    blockers = [x.lower() for x in onboarding.get("blockers", [])]
    energy = (onboarding.get("energy") or "").lower()
    support_style = (onboarding.get("support_style") or "").lower()

    title = "Personal Reset"
    subtitle = "A moment to return to yourself"
    lines = []

    if any("peace" in item or "calm" in item for item in intentions):
        title = "Calm Within"
        subtitle = "A softer space for peace"
        lines.extend([
            "You are safe in this moment.",
            "Nothing needs to be solved all at once.",
            "With each breath, your mind becomes quieter."
        ])

    if any("confidence" in item or "self" in item for item in intentions + blockers):
        title = "Return to Self-Trust"
        subtitle = "A gentle confidence reset"
        lines.extend([
            "You do not need to earn your worth.",
            "You are allowed to trust yourself again.",
            "Your voice matters, and your presence is enough."
        ])

    if any("rest" in item or "sleep" in item for item in intentions) or "drained" in energy:
        title = "Evening Exhale"
        subtitle = "Let your mind soften before rest"
        lines.extend([
            "Your body is allowed to rest now.",
            "You can release the weight of today.",
            "Sleep begins with letting go."
        ])

    if not lines:
        lines = [
            "Take one slow breath in.",
            "Take one slow breath out.",
            "Come back to yourself, one moment at a time.",
            "You are here, and that is enough for now."
        ]

    if any("overwhelmed" in item or "anxious" in item for item in moods + blockers):
        lines.append("You do not have to carry everything at once.")

    if "gentle" in support_style:
        lines.append("Let this moment be soft and steady.")
    elif "direct" in support_style:
        lines.append("You are ready to move forward with clarity.")

    script_text = " ".join(lines)

    return {
        "title": title,
        "subtitle": subtitle,
        "script_text": script_text,
        "session_type": "personalized_affirmation",
        "cover_emoji": "✨",
    }
