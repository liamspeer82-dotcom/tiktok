# TikTok-style feed demo for Windows PowerShell ISE.
# Press F5 in ISE. This writes a standalone HTML app beside this script and opens it.

$ErrorActionPreference = 'Stop'
$outputPath = Join-Path $PSScriptRoot 'tiktok-ise-app.html'

$html = @'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ClipLoop — short videos</title>
  <style>
    * { box-sizing: border-box; }
    body { margin: 0; background: #101014; color: #fff; font: 15px Arial, sans-serif; }
    .shell { width: min(100%, 440px); height: 100dvh; min-height: 580px; margin: auto; position: relative; overflow: hidden; background: #08080b; }
    header { position: absolute; z-index: 2; top: 0; left: 0; right: 0; display: flex; justify-content: space-between; align-items: center; padding: 18px; background: linear-gradient(#0009, transparent); }
    .logo { font-size: 23px; font-weight: 800; letter-spacing: -.8px; }
    .tabs { display: flex; gap: 18px; font-weight: bold; }
    .tabs span { opacity: .65; padding-bottom: 5px; }
    .tabs .selected { opacity: 1; border-bottom: 2px solid white; }
    .feed { height: 100%; overflow-y: auto; scroll-snap-type: y mandatory; scrollbar-width: none; }
    .feed::-webkit-scrollbar { display: none; }
    .post { height: 100%; min-height: 580px; position: relative; scroll-snap-align: start; overflow: hidden; background: linear-gradient(145deg,#24484c,#6b485e 55%,#e89064); }
    .post:nth-child(2) { background: linear-gradient(145deg,#121c3a,#476c87 55%,#e7a65a); }
    .post:nth-child(3) { background: linear-gradient(145deg,#391d26,#ad4c42 50%,#f0c77b); }
    .scene { position: absolute; inset: 0; display: grid; place-items: center; overflow: hidden; }
    .scene::before,.scene::after { content: ''; position: absolute; border-radius: 50%; filter: blur(1px); }
    .scene::before { width: 65vw; height: 65vw; max-width: 310px; max-height: 310px; background: #ffffff19; top: 17%; left: -10%; }
    .scene::after { width: 78vw; height: 78vw; max-width: 360px; max-height: 360px; background: #0002; bottom: -28%; right: -17%; }
    .emoji { position: relative; z-index: 1; font-size: clamp(100px, 30vw, 165px); filter: drop-shadow(0 18px 22px #0005); animation: float 4s ease-in-out infinite; }
    @keyframes float { 50% { transform: translateY(-13px) rotate(2deg); } }
    .shade { position: absolute; inset: 25% 0 0; background: linear-gradient(transparent, #000b); }
    .info { position: absolute; left: 18px; right: 88px; bottom: 92px; z-index: 1; text-shadow: 0 2px 6px #0008; }
    .user { font-weight: 700; margin-bottom: 9px; }
    .caption { line-height: 1.4; margin: 0 0 9px; }
    .tags { font-weight: 700; margin-bottom: 11px; }
    .music { font-size: 13px; }
    .actions { position: absolute; right: 15px; bottom: 100px; z-index: 1; display: grid; gap: 18px; justify-items: center; }
    .action { border: 0; color: #fff; background: #ffffff2a; width: 52px; height: 52px; border-radius: 50%; font-size: 24px; cursor: pointer; }
    .action.liked { color: #ff4368; background: #fff; }
    .count { font-size: 12px; font-weight: 700; margin-top: -14px; text-shadow: 0 1px 5px #000; }
    nav { position: absolute; z-index: 2; bottom: 0; left: 0; right: 0; padding: 13px 10px 20px; display: flex; justify-content: space-around; background: #08080bf2; }
    nav button { color: #ddd; background: none; border: 0; font-size: 11px; display: grid; gap: 4px; justify-items: center; cursor: pointer; }
    nav strong { font-size: 20px; }
    nav .active { color: white; }
    .create { border: 0; border-radius: 9px; width: 44px; height: 29px; font-size: 24px; line-height: 24px; color: #111; background: linear-gradient(90deg,#65e8e1 0 18%,white 18% 82%,#ff4d73 82%); }
    @media (min-width: 600px) { .shell { height: min(94vh, 850px); min-height: 580px; border-radius: 18px; margin-top: 3vh; box-shadow: 0 20px 70px #0008; } }
  </style>
</head>
<body>
  <main class="shell">
    <header><div class="logo">ClipLoop</div><div class="tabs"><span>Following</span><span class="selected">For You</span></div><div aria-label="Search">⌕</div></header>
    <section class="feed" id="feed" aria-label="Short video feed"></section>
    <nav aria-label="Main navigation">
      <button class="active"><strong>⌂</strong>Home</button><button><strong>⌕</strong>Discover</button>
      <button aria-label="Create"><span class="create">+</span></button><button><strong>✉</strong>Inbox</button><button><strong>◉</strong>Profile</button>
    </nav>
  </main>
  <script>
    const clips = [
      { user: '@maya.moves', emoji: '🌅', caption: 'Chasing the last light of the day ✨', tags: '#sunset #goodvibes', song: 'Original sound — maya', likes: 1240, comments: 38, bg: 'linear-gradient(145deg,#24484c,#6b485e 55%,#e89064)' },
      { user: '@leo.explores', emoji: '🏔️', caption: 'POV: you finally took that weekend trip.', tags: '#travel #outside', song: 'Somewhere New — Leo', likes: 892, comments: 21, bg: 'linear-gradient(145deg,#121c3a,#476c87 55%,#e7a65a)' },
      { user: '@nina.cooks', emoji: '🍜', caption: 'The cozy bowl I make on rainy nights 🍜', tags: '#food #comfortfood', song: 'Kitchen sessions — Nina', likes: 2401, comments: 74, bg: 'linear-gradient(145deg,#391d26,#ad4c42 50%,#f0c77b)' }
    ];
    const feed = document.getElementById('feed');
    clips.forEach((clip) => {
      const post = document.createElement('article');
      post.className = 'post';
      post.style.background = clip.bg;
      post.innerHTML = `<div class="scene"><span class="emoji">${clip.emoji}</span></div><div class="shade"></div><div class="info"><div class="user">${clip.user}</div><p class="caption">${clip.caption}</p><div class="tags">${clip.tags}</div><div class="music">♫ &nbsp;${clip.song}</div></div><div class="actions"><button class="action like" aria-label="Like">♡</button><span class="count likes">${clip.likes.toLocaleString()}</span><button class="action" aria-label="Comment">▢</button><span class="count">${clip.comments}</span><button class="action" aria-label="Share">↗</button><span class="count">Share</span></div>`;
      feed.appendChild(post);
    });
    feed.addEventListener('click', (event) => {
      const button = event.target.closest('.like');
      if (!button) return;
      const count = button.nextElementSibling;
      const wasLiked = button.classList.toggle('liked');
      button.textContent = wasLiked ? '♥' : '♡';
      const value = Number(count.textContent.replace(/,/g, '')) + (wasLiked ? 1 : -1);
      count.textContent = value.toLocaleString();
    });
  </script>
</body>
</html>
'@

Set-Content -Path $outputPath -Value $html -Encoding UTF8
Write-Host "Created app: $outputPath" -ForegroundColor Green
Start-Process $outputPath
