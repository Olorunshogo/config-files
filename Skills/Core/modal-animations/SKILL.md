---
name: modal-animations
description: Convention for animated modals across three approaches (framer-motion AnimatePresence + motion, GSAP timelines with gsap.context, and plain CSS transitions / keyframes), plus React Bits copy-paste components. Covers how to choose an approach, the bottom-sheet pattern (mobile) / centered panel (desktop), full-screen overlays, backdrop cursor/click rules, staggered list animations, and reduced-motion handling.
---

# Modal Animations

There are three sanctioned animation approaches. Pick one per project, not one per modal, so a codebase does not end up with three animation systems.

---

## Choosing an approach

| Situation | Reach for |
| --- | --- |
| `framer-motion` already in `package.json` | framer-motion |
| `gsap` already in `package.json` | GSAP |
| No animation dependency, simple enter/exit fade and rise | CSS transitions / keyframes |
| No animation dependency, complex sequence, and you may add one | framer-motion for declarative mount/unmount, GSAP for timelines |
| Multi-step chained reveal, ScrollTrigger, morphing or path animation, precise orchestration across many elements | GSAP |
| Simple enter/exit, presence-driven, list stagger | framer-motion |
| One modal only, nothing else in the app animates | CSS, do not add a library |
| Decorative or marketing surface wanting a ready-made effect | React Bits, after checking what it depends on |

Rules that hold regardless of approach:

- Never add an animation library for a single modal.
- Check `package.json` before writing any animation code.
- Every approach must respect `prefers-reduced-motion`.

---

## Approach 1: framer-motion

The default when `framer-motion` is already a dependency. Use `AnimatePresence` + `motion`.

### Bottom-sheet / centered modal

Use this for: PayRent, Escalation, TopUp, Withdraw, CreateGoal, AddFunds, and similar action modals.

```tsx
// === Call site
// Always wrap in AnimatePresence so the exit animation fires on unmount
<AnimatePresence>
  {isOpen && <MyModal onClose={close} />}
</AnimatePresence>

// === Modal component
return (
  <>
    {/* Backdrop, cursor-pointer signals it is dismissible */}
    <motion.div
      className="fixed inset-0 z-40 cursor-pointer bg-black/50 backdrop-blur-sm"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.2 }}
      onClick={onClose}
      aria-hidden="true"
    />

    {/* Panel wrapper, pointer-events-none so backdrop click works through it */}
    <div className="pointer-events-none fixed inset-0 z-50 flex items-end justify-center lg:items-center">
      <motion.div
        className="bg-surface-canvas pointer-events-auto w-full max-w-md rounded-t-2xl border border-[#E4E4E7] p-6 lg:rounded-xl"
        initial={{ y: 48, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        exit={{ y: 48, opacity: 0 }}
        transition={{ type: 'spring', damping: 28, stiffness: 320 }}
      >
        {/* content */}
      </motion.div>
    </div>
  </>
);
```

For modals that use `ModalShell` (Wallet, Savings pages), the shell already handles this pattern with `key="backdrop"` / `key="panel"` and the AnimatePresence lives inside the shell, so no outer AnimatePresence is needed at the call site.

### Full-screen overlay modal (e.g. DocViewer)

```tsx
<motion.div
  className="bg-surface-canvas fixed inset-0 z-50 flex flex-col"
  initial={{ opacity: 0, y: 16 }}
  animate={{ opacity: 1, y: 0 }}
  exit={{ opacity: 0, y: 16 }}
  transition={{ type: 'spring', damping: 28, stiffness: 320 }}
>
  {/* content */}
</motion.div>
```

Wrap at call site with `<AnimatePresence>`.

### Staggered list animations

When rendering a grid of cards that mount on page load or filter change, use staggered entrance:

```tsx
// === Wrap the grid in AnimatePresence mode="wait" keyed by the current filter/page
<AnimatePresence mode="wait">
  <motion.div
    key={`${filter}-${page}`}
    initial={{ opacity: 0 }}
    animate={{ opacity: 1 }}
    exit={{ opacity: 0 }}
    transition={{ duration: 0.15 }}
    className="grid ..."
  >
    {items.map((item, i) => (
      <motion.div
        key={item.id}
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.3, delay: i * 0.06 }}
      >
        {/* card content */}
      </motion.div>
    ))}
  </motion.div>
</AnimatePresence>
```

---

## Approach 2: GSAP

Use GSAP when the animation is timeline-driven or physics-heavy:

- Multi-step chained reveals where step order and overlap matter.
- Scroll-triggered animation via `ScrollTrigger`.
- Morphing and path animation.
- Precise orchestration across many elements at once.

### React rules

- Scope every animation with `gsap.context()` bound to a container `ref`.
- Create the context inside `useLayoutEffect`, not `useEffect`, so the first frame is never unanimated.
- Always `return () => ctx.revert()` so GSAP undoes its inline styles and kills its tweens on unmount.
- GSAP has no `AnimatePresence` equivalent, so exit animations need a manual "animate out, then unmount" callback. The parent keeps the component mounted until GSAP calls back.

### Timeline modal

```tsx
// === Types
interface GsapModalProps {
  onClose: () => void;
}

// === Component
export function GsapModal({ onClose }: GsapModalProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const timelineRef = useRef<gsap.core.Timeline | null>(null);

  useLayoutEffect(() => {
    const ctx = gsap.context(() => {
      const tl = gsap.timeline({ defaults: { ease: 'power3.out' } });

      tl.to('[data-gsap="backdrop"]', { opacity: 1, duration: 0.2 })
        .fromTo(
          '[data-gsap="panel"]',
          { y: 48, opacity: 0 },
          { y: 0, opacity: 1, duration: 0.35 },
          '<0.05'
        )
        .fromTo(
          '[data-gsap="row"]',
          { y: 16, opacity: 0 },
          { y: 0, opacity: 1, duration: 0.25, stagger: 0.06 },
          '-=0.15'
        );

      timelineRef.current = tl;
    }, containerRef);

    return () => ctx.revert();
  }, []);

  // === Exit: animate out first, unmount only in the completion callback
  const handleClose = (): void => {
    const ctx = gsap.context(() => {
      gsap.timeline({ onComplete: onClose })
        .to('[data-gsap="panel"]', { y: 48, opacity: 0, duration: 0.22, ease: 'power2.in' })
        .to('[data-gsap="backdrop"]', { opacity: 0, duration: 0.18 }, '<');
    }, containerRef);

    // revert after the timeline finishes, not immediately
    window.setTimeout(() => ctx.revert(), 400);
  };

  return (
    <div ref={containerRef}>
      <div
        data-gsap="backdrop"
        className="fixed inset-0 z-40 cursor-pointer bg-black/50 opacity-0 backdrop-blur-sm"
        onClick={handleClose}
        aria-hidden="true"
      />
      <div className="pointer-events-none fixed inset-0 z-50 flex items-end justify-center lg:items-center">
        <div
          data-gsap="panel"
          className="bg-surface-canvas pointer-events-auto flex w-full max-w-md flex-col gap-4 rounded-t-2xl border border-[#E4E4E7] p-6 opacity-0 lg:rounded-xl"
        >
          {items.map((item) => (
            <div key={item.id} data-gsap="row" className="opacity-0">
              {item.label}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
```

The parent keeps the modal mounted and lets the child decide when it is done:

```tsx
// === Call site
{isOpen && <GsapModal onClose={() => setIsOpen(false)} />}
```

### ScrollTrigger

```tsx
useLayoutEffect(() => {
  const ctx = gsap.context(() => {
    gsap.from('[data-gsap="reveal"]', {
      y: 40,
      opacity: 0,
      duration: 0.6,
      stagger: 0.1,
      scrollTrigger: {
        trigger: containerRef.current,
        start: 'top 75%',
        toggleActions: 'play none none reverse',
      },
    });
  }, containerRef);

  return () => ctx.revert();
}, []);
```

`ctx.revert()` also kills the ScrollTriggers created inside the context, so no separate teardown is needed.

### Reduced motion

```tsx
const ctx = gsap.context(() => {
  gsap.matchMedia().add('(prefers-reduced-motion: no-preference)', () => {
    // full timeline here
  });
}, containerRef);
```

Elements must be visible by default in CSS when the timeline is skipped, so never rely on an opening tween to reveal content for reduced-motion users.

---

## Approach 3: CSS transitions and keyframes

Correct when the project has no animation dependency and the interaction is a simple enter and exit fade with a rise. Do not pull in a whole animation library for one modal.

The pattern:

- Define `@keyframes` in `globals.css` or extend them in `tailwind.config`.
- Drive the classes from a `data-state="open" | "closed"` attribute, or from a mounted boolean.
- Delay unmount by the exit duration so the closing frames actually render.
- Guard everything with `prefers-reduced-motion`.

### Keyframes in globals.css

```css
/* === Modal keyframes */
@keyframes modal-backdrop-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes modal-backdrop-out {
  from { opacity: 1; }
  to { opacity: 0; }
}

@keyframes modal-panel-in {
  from { opacity: 0; transform: translateY(48px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes modal-panel-out {
  from { opacity: 1; transform: translateY(0); }
  to { opacity: 0; transform: translateY(48px); }
}

/* === State bindings */
[data-state='open'].modal-backdrop {
  animation: modal-backdrop-in 200ms ease-out both;
}
[data-state='closed'].modal-backdrop {
  animation: modal-backdrop-out 180ms ease-in both;
}
[data-state='open'].modal-panel {
  animation: modal-panel-in 280ms cubic-bezier(0.22, 1, 0.36, 1) both;
}
[data-state='closed'].modal-panel {
  animation: modal-panel-out 200ms ease-in both;
}

/* === Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .modal-backdrop,
  .modal-panel {
    animation: none !important;
    opacity: 1;
    transform: none;
  }
}
```

Equivalent `tailwind.config` extension if you prefer utility classes:

```ts
// === tailwind.config.ts
extend: {
  keyframes: {
    'modal-panel-in': {
      from: { opacity: '0', transform: 'translateY(48px)' },
      to: { opacity: '1', transform: 'translateY(0)' },
    },
    'modal-panel-out': {
      from: { opacity: '1', transform: 'translateY(0)' },
      to: { opacity: '0', transform: 'translateY(48px)' },
    },
  },
  animation: {
    'modal-panel-in': 'modal-panel-in 280ms cubic-bezier(0.22,1,0.36,1) both',
    'modal-panel-out': 'modal-panel-out 200ms ease-in both',
  },
}
```

### Backdrop and panel component

```tsx
// === Types
interface CssModalProps {
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
}

const EXIT_MS: number = 200;

// === Component
export function CssModal({ isOpen, onClose, children }: CssModalProps) {
  const [isMounted, setIsMounted] = useState<boolean>(isOpen);
  const [state, setState] = useState<'open' | 'closed'>('closed');

  useEffect(() => {
    if (isOpen) {
      setIsMounted(true);
      // next frame so the closed styles commit before switching to open
      const raf = requestAnimationFrame(() => setState('open'));
      return () => cancelAnimationFrame(raf);
    }

    setState('closed');
    const timer = window.setTimeout(() => setIsMounted(false), EXIT_MS);
    return () => window.clearTimeout(timer);
  }, [isOpen]);

  if (!isMounted) return null;

  return (
    <>
      <div
        data-state={state}
        className="modal-backdrop fixed inset-0 z-40 cursor-pointer bg-black/50 backdrop-blur-sm"
        onClick={onClose}
        aria-hidden="true"
      />
      <div className="pointer-events-none fixed inset-0 z-50 flex items-end justify-center lg:items-center">
        <div
          data-state={state}
          role="dialog"
          aria-modal="true"
          className="modal-panel bg-surface-canvas pointer-events-auto flex w-full max-w-md flex-col gap-4 rounded-t-2xl border border-[#E4E4E7] p-6 lg:rounded-xl"
        >
          {children}
        </div>
      </div>
    </>
  );
}
```

Notes:

- `EXIT_MS` must match the longest exit animation, otherwise the panel is yanked mid frame.
- The `requestAnimationFrame` step matters: setting `open` in the same tick as mount skips the entrance.
- Sibling spacing inside the panel comes from `gap` on the flex parent, never from margins or `space-y-*`.

---

## React Bits

[React Bits](https://reactbits.dev) is a library of copy-paste animated React components: text animations, animated backgrounds, interactive cards, and similar effects.

How to use it:

- Components are copied into the codebase, not installed as a dependency. There is no package to upgrade, so treat pasted code as code you now own and maintain.
- Many components depend on GSAP or framer-motion under the hood. Read the source of the specific component before pasting and check which library it pulls in, because it can silently add a dependency the project does not have.
- If the component needs a library the project does not already use, that is a project-level decision, not a per-component one. Line it up with the approach chosen in the decision table above.
- They suit decorative and marketing surfaces: landing pages, hero sections, empty states, promo panels. Do not use them for core app chrome such as modals, dialogs, navigation, or forms, where accessibility and predictable behaviour matter more than the effect.
- Keep pasted components in a clearly named directory, for example `src/components/react-bits/`, so their origin is obvious to the next reader.
- Strip components you do not use. Do not leave an unused catalogue sitting in the repo.
- Apply the project's own conventions after pasting: typing rules, comment style, and Tailwind breakpoints. Pasted code arrives in someone else's style.

---

## Cursor convention

Applies to every approach.

- Modal backdrop: always `cursor-pointer`, since it closes the modal on click.
- Hover rows (e.g. transaction list rows): `hover:bg-surface-container-low` but NO `cursor-pointer`, because they are not interactive actions, just visual feedback.
- All buttons and links: `cursor-pointer` unconditionally.
