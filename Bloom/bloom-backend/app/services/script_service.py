def build_personalized_script(onboarding: dict) -> dict:
    moods = onboarding.get("moods", []) or []
    intentions = onboarding.get("intentions", []) or []
    blockers = onboarding.get("blockers", []) or []
    energy = onboarding.get("energy") or ""
    support_style = onboarding.get("support_style") or ""

    mood_text = ", ".join(moods[:2]) if moods else "a little heavy"
    intention_text = ", ".join(intentions[:2]) if intentions else "calm and clarity"
    blocker_text = blockers[0] if blockers else "overthinking"

    title = "Gentle Reset"
    subtitle = "A moment to breathe and return to yourself"
    cover_emoji = "🌿"

    if any("rest" in item.lower() or "sleep" in item.lower() for item in intentions):
        title = "Evening Exhale"
        subtitle = "Let your mind soften before rest"
        cover_emoji = "🌙"

    if any("confidence" in item.lower() or "self" in item.lower() for item in intentions + blockers):
        title = "Return to Self-Trust"
        subtitle = "A gentle reminder of your worth"
        cover_emoji = "✨"

    script_text = f"""
Hey… take a moment.

You don’t have to carry everything right now.

If you’ve been feeling {mood_text}, that’s okay.

Just breathe in… slowly…

And gently breathe out.

There’s nothing you need to fix in this moment.

Even with {blocker_text}, you’re still showing up.

And that matters.

Let your shoulders drop.

Let your mind soften.

You don’t need to rush anything.

Right now, you’re allowed to pause.

You’re allowed to reset.

And with time, you’re moving closer to {intention_text}.

Even if it doesn’t feel like it yet.

Stay here for a few seconds.

You’re doing better than you think.

And you are exactly where you need to be.
""".strip()

    return {
        "title": title,
        "subtitle": subtitle,
        "script_text": script_text,
        "session_type": "personalized_affirmation",
        "cover_emoji": cover_emoji,
    }
