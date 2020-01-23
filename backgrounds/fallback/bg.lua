background.LoadTexture("bgTex", "bg.png")
background.LoadTexture("centerClearTex", "center_clear.png")
background.LoadTexture("centerFailTex", "center_fail.png")
background.LoadTexture("fgTex", "fg.png")
background.LoadTexture("particlesTex", "particles.png")
background.LoadTexture("ringTex", "ring.png")
background.LoadTexture("sidesClearTex", "sides_clear.png")
background.LoadTexture("sidesFailTex", "sides_fail.png")

function render_bg(deltaTime)
  background.DrawShader()
end
