PhiVector Landing Page
Tactical chrome aesthetics for precision-engineered systems.
Overview
Single-page landing site for PhiVector—umbrella brand for PhiLaunch and future automation/orchestration tools. Built with biomechanical chrome design language, tactical UI elements, and zero marketing fluff.
Design Philosophy

Fourth iteration mindset: Refuse good-enough solutions
Tactical military aesthetic: Chrome, circuits, precision
Factual over promotional: No analogies, no fluff—just what it does
Visual quality = product quality: Brand is as important as code

Technical Stack

Pure HTML/CSS/JavaScript (no frameworks, no dependencies)
Google Fonts: Orbitron (headers), Rajdhani (body)
SVG for high-DPI graphics (barbs, blast doors)
Responsive design (mobile-first)
Zero external assets required

Key Features
Visual Elements

Biomechanical chrome title: T-800/HR Giger fusion with diamond plate reinforcement
Breathing circuit veins: Animated background pulsing chrome-to-green
Serrated barb brackets: Bee stinger microscopic aesthetic with venom glow
Hydraulic blast door menu: Premium SVG side-sliding doors with hinge details
Tactical scroll indicator: Chrome track with animated green chevron

Interaction

Side panel navigation slides from right
Click blast doors or ESC to close
Smooth scroll indicator (hidden on mobile)
Dark overlay fade for panel focus

Content Structure

Hero section: Title, tagline, subtitle
Side panel: PhiLaunch flagship + resources (GitHub, docs, roadmap, contact)
Minimal, scalable—ready for product expansion

Color Palette
css--primary-bg: #0a0a0a        /* Deep black */
--tactical-green: #00FF00     /* Accent/glow */
--chrome-light: #C0C0C0       /* Primary text */
--chrome-mid: #8B8B8B         /* Secondary elements */
--chrome-dark: #505050        /* Shadows */
```

## Typography

- **Headers**: Orbitron (tactical/tech aesthetic)
- **Body**: Rajdhani (clean military-style)
- Letter-spacing, golden ratio proportions throughout

## File Structure
```
marketing/
+-- index.html          # Single-file landing page (this is it)
+-- assets/            # Design assets (NOT for landing page)
    +-- design-assets/ # PhiGEN/other project assets
    +-- images/        # Logos, textures, backgrounds
    +-- ...
Deployment
GitHub Pages

Push index.html to marketing/ directory
Enable GitHub Pages in repo settings
Set source to main branch, /marketing folder
Site live at: https://stryk91.github.io/PhiLaunch/

Local Testing
bashcd /home/STRYK/marketing
python3 -m http.server 8000
# Open browser to http://localhost:8000
Browser Compatibility

Chrome/Edge: Full support
Firefox: Full support
Safari: Full support (webkit prefixes included)
Mobile: Responsive breakpoints at 768px

Performance

Page weight: ~50KB (including inline CSS/JS)
Load time: <500ms on 3G
No external dependencies (except Google Fonts CDN)
Zero JavaScript frameworks

Design Session Notes
Built with Claude (Desktop Claude/DC) in collaboration with STRYKER over ~190k tokens. Iterative process:

Base chrome title + circuit background
Biomechanical texture refinement (T-800/Giger fusion)
SVG barbs with organic curves (microscopic bee stinger)
Premium blast door menu icon (12-stop gradients, hinge bolts)
Tactical side panel with factual PhiLaunch specs
Scroll indicator with chrome track

Key directive: One element at a time, pixel-perfect, no overflow.
Future Expansion
When products hit milestones:

Add content sections below hero (scroll reveals)
Expand side panel with additional products
Integrate actual documentation links
Add hydraulic sound effect to blast doors

Keep it lean—only show what supports the devops/remote ops narrative.
Brand Contrast
What we're NOT (reference: other AI's attempt):

Generic corporate SaaS template
Emoji icons and marketing fluff
"Best-in-class" buzzword spam
Boring gradient backgrounds
Standard card layouts

What we ARE:

Precision-engineered visual identity
Tactical weapons-grade aesthetics
Dimensional chrome with actual depth
Factual, direct, no posturing

License
Proprietary—PhiVector branding and design assets.
Code structure can be referenced for learning.
Contact

GitHub: https://github.com/Stryk91/PhiLaunch
Location: Melbourne, Australia
Trademark: Pending


Built by: STRYKER + Claude (DC)
Session: 2025-11-15
Philosophy: Brand IS product. No compromises.