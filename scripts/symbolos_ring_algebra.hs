-- SymbolOS Ring Algebra — Haskell
-- ══════════════════════════════════════════════════════════════
--
-- A pure-functional proof that SymbolOS Ring 0–7 forms a genuine
-- mathematical ring (Z/8Z) with verified algebraic properties.
--
-- This isn't metaphor. The naming was always load-bearing.
--
-- Usage:
--   runghc scripts/symbolos_ring_algebra.hs
--   # or compile:
--   ghc scripts/symbolos_ring_algebra.hs -o ring_algebra && ./ring_algebra
--
-- Zero dependencies. Pure Haskell. Runs on GHC 8.10+.
--
-- 🦊 "They called it a 'ring model' because it sounded nice.
--     Turns out it was algebraically true the whole time.
--     Rhy considers this the funniest thing in the repo." — Rhy

module Main where

import Data.List (intercalate, nub)

-- ══════════════════════════════════════════════════════════════
-- § 1. The Ring: Z/8Z (integers modulo 8)
-- ══════════════════════════════════════════════════════════════

-- | A Ring element is an integer in [0, 7].
-- This is the type-level representation of a SymbolOS ring layer.
newtype Ring = Ring { unRing :: Int }
  deriving (Eq, Ord)

-- Smart constructor: always reduces mod 8
mkRing :: Int -> Ring
mkRing n = Ring (n `mod` 8)

instance Show Ring where
  show (Ring n) = "R" ++ show n

-- | Ring addition (modular)
-- R3 ⊕ R5 = R0 (prediction + guardrails = kernel truth)
-- This is not arbitrary — it means combining prediction with safety
-- brings you back to fundamental invariants.
ringAdd :: Ring -> Ring -> Ring
ringAdd (Ring a) (Ring b) = mkRing (a + b)

-- | Ring multiplication (modular)
-- Scaling one ring layer by another. R2 ⊗ R4 = R0.
-- Retrieval scaled by architecture yields kernel truth.
ringMul :: Ring -> Ring -> Ring
ringMul (Ring a) (Ring b) = mkRing (a * b)

-- | Additive identity: R0 (Kernel)
-- The kernel is the identity element. Adding it changes nothing.
-- This is why R0 holds the invariants that never change.
ringZero :: Ring
ringZero = mkRing 0

-- | Multiplicative identity: R1 (Task)
-- The active task context is the multiplicative identity.
-- Scaling by R1 preserves what you have. "What are we doing right now?"
-- doesn't change the answer — it frames it.
ringOne :: Ring
ringOne = mkRing 1

-- | Additive inverse: -a ≡ (8-a) mod 8
-- Every ring has an undo. R3's inverse is R5 (prediction's inverse
-- is guardrails). R4's inverse is R4 (architecture is its own inverse).
ringNeg :: Ring -> Ring
ringNeg (Ring a) = mkRing (8 - a)

-- Operator aliases for readability
infixl 6 ⊕
(⊕) :: Ring -> Ring -> Ring
(⊕) = ringAdd

infixl 7 ⊗
(⊗) :: Ring -> Ring -> Ring
(⊗) = ringMul

-- ══════════════════════════════════════════════════════════════
-- § 2. The Symbol Map: Ring → Meaning
-- ══════════════════════════════════════════════════════════════

data RingMeaning = RingMeaning
  { rmGlyph       :: String
  , rmLabel       :: String
  , rmColor       :: String
  , rmWavelength  :: Double  -- approximate nm
  , rmDescription :: String
  }

ringMeaning :: Ring -> RingMeaning
ringMeaning (Ring 0) = RingMeaning "⚓" "Kernel"       "#FADA5E" 575.0 "Identity / grounding / invariants"
ringMeaning (Ring 1) = RingMeaning "🧭" "Task"         "#228B22" 530.0 "Active context / orchestration"
ringMeaning (Ring 2) = RingMeaning "🪞" "Retrieval"    "#E49B0F" 580.0 "Memory / continuity"
ringMeaning (Ring 3) = RingMeaning "🌀" "Prediction"   "#FF8C00" 600.0 "Anticipation / PreEmotion / strategy"
ringMeaning (Ring 4) = RingMeaning "🧩" "Architecture" "#8B00FF" 420.0 "Design / synthesis / Fi+Ti bridge"
ringMeaning (Ring 5) = RingMeaning "☂️"  "Guardrails"   "#FF2400" 640.0 "Safety / privacy / boundaries"
ringMeaning (Ring 6) = RingMeaning "🧪" "Verification" "#0000CD" 470.0 "Testing / evidence / proof"
ringMeaning (Ring 7) = RingMeaning "🗃️"  "Persistence"  "#FFD700" 585.0 "Logging / storage / shipping"
ringMeaning _        = RingMeaning "?"  "Unknown"      "#000000"   0.0 "Outside the ring model"

-- ══════════════════════════════════════════════════════════════
-- § 3. Algebraic Property Verification (Exhaustive)
-- ══════════════════════════════════════════════════════════════

-- | All elements of Z/8Z
allRings :: [Ring]
allRings = map mkRing [0..7]

-- | Verify: ∀ a,b,c ∈ R: (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c)
-- Addition is associative.
verifyAssocAdd :: Bool
verifyAssocAdd = and
  [ (a ⊕ b) ⊕ c == a ⊕ (b ⊕ c)
  | a <- allRings, b <- allRings, c <- allRings
  ]

-- | Verify: ∀ a ∈ R: a ⊕ 0 = 0 ⊕ a = a
-- R0 (Kernel) is the additive identity.
verifyIdentityAdd :: Bool
verifyIdentityAdd = and
  [ a ⊕ ringZero == a && ringZero ⊕ a == a
  | a <- allRings
  ]

-- | Verify: ∀ a ∈ R: a ⊕ (-a) = 0
-- Every ring layer has an inverse that returns to kernel.
verifyInverseAdd :: Bool
verifyInverseAdd = and
  [ a ⊕ ringNeg a == ringZero
  | a <- allRings
  ]

-- | Verify: ∀ a,b ∈ R: a ⊕ b = b ⊕ a
-- Addition is commutative (abelian group under +).
verifyCommutAdd :: Bool
verifyCommutAdd = and
  [ a ⊕ b == b ⊕ a
  | a <- allRings, b <- allRings
  ]

-- | Verify: ∀ a,b,c ∈ R: (a ⊗ b) ⊗ c = a ⊗ (b ⊗ c)
-- Multiplication is associative.
verifyAssocMul :: Bool
verifyAssocMul = and
  [ (a ⊗ b) ⊗ c == a ⊗ (b ⊗ c)
  | a <- allRings, b <- allRings, c <- allRings
  ]

-- | Verify: ∀ a ∈ R: a ⊗ 1 = 1 ⊗ a = a
-- R1 (Task) is the multiplicative identity.
verifyIdentityMul :: Bool
verifyIdentityMul = and
  [ a ⊗ ringOne == a && ringOne ⊗ a == a
  | a <- allRings
  ]

-- | Verify: ∀ a,b,c ∈ R: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
-- Left distributivity.
verifyDistribLeft :: Bool
verifyDistribLeft = and
  [ a ⊗ (b ⊕ c) == (a ⊗ b) ⊕ (a ⊗ c)
  | a <- allRings, b <- allRings, c <- allRings
  ]

-- | Verify: ∀ a,b,c ∈ R: (a ⊕ b) ⊗ c = (a ⊗ c) ⊕ (b ⊗ c)
-- Right distributivity.
verifyDistribRight :: Bool
verifyDistribRight = and
  [ (a ⊕ b) ⊗ c == (a ⊗ c) ⊕ (b ⊗ c)
  | a <- allRings, b <- allRings, c <- allRings
  ]

-- | Verify: ∀ a,b ∈ R: a ⊗ b = b ⊗ a
-- Z/8Z is a commutative ring.
verifyCommutMul :: Bool
verifyCommutMul = and
  [ a ⊗ b == b ⊗ a
  | a <- allRings, b <- allRings
  ]

-- ══════════════════════════════════════════════════════════════
-- § 4. Resonance & Harmonic Analysis
-- ══════════════════════════════════════════════════════════════

-- | Harmonic distance: minimum of clockwise and counterclockwise
-- distance on the ring. This is the Z/8Z metric.
harmonicDistance :: Ring -> Ring -> Int
harmonicDistance (Ring a) (Ring b) =
  let d = abs (a - b)
  in min d (8 - d)

-- | Two rings are "consonant" if their harmonic distance is ≤ 2
-- (adjacent or once-removed). Like musical consonance.
isConsonant :: Ring -> Ring -> Bool
isConsonant a b = harmonicDistance a b <= 2

-- | The "orbit" of a ring element under repeated addition of a generator.
-- Shows how one ring layer cycles through all others.
orbit :: Ring -> [Ring]
orbit gen = take 8 $ iterate (⊕ gen) ringZero

-- | Find which ring elements are generators (orbit covers all of Z/8Z).
-- In Z/8Z, generators are elements coprime to 8: {1, 3, 5, 7}.
generators :: [Ring]
generators = filter (\g -> length (nub (orbit g)) == 8) allRings

-- | Annihilator pairs: a ⊗ b = R0 (kernel absorbs their product)
annihilators :: [(Ring, Ring)]
annihilators =
  [ (a, b)
  | a <- allRings, b <- allRings
  , a /= ringZero, b /= ringZero
  , a ⊗ b == ringZero
  ]

-- ══════════════════════════════════════════════════════════════
-- § 5. Additive Inverse Interpretation
-- ══════════════════════════════════════════════════════════════

-- | Show the "philosophical inverse" of each ring layer.
-- When two inverses combine, they return to kernel truth (R0).
inversePairs :: [(Ring, Ring, String)]
inversePairs =
  [ (r, ringNeg r, interpret r (ringNeg r))
  | r <- allRings
  , unRing r <= unRing (ringNeg r)  -- avoid duplicates
  ]

interpret :: Ring -> Ring -> String
interpret (Ring 0) (Ring 0) = "Kernel is its own inverse: truth + truth = truth"
interpret (Ring 1) (Ring 7) = "Task + Persistence = Kernel (doing + remembering = being)"
interpret (Ring 2) (Ring 6) = "Retrieval + Verification = Kernel (memory + proof = truth)"
interpret (Ring 3) (Ring 5) = "Prediction + Guardrails = Kernel (anticipation + safety = truth)"
interpret (Ring 4) (Ring 4) = "Architecture is its own inverse: design + design = truth"
interpret _ _               = "(structural pairing)"

-- ══════════════════════════════════════════════════════════════
-- § 6. Output
-- ══════════════════════════════════════════════════════════════

check :: String -> Bool -> String
check label True  = "  ✅ " ++ label
check label False = "  ❌ " ++ label ++ " — FAILED"

main :: IO ()
main = do
  putStrLn ""
  putStrLn "╔══════════════════════════════════════════════════════════╗"
  putStrLn "║  SymbolOS Ring Algebra                      [Haskell]  ║"
  putStrLn "║  Z/8Z Algebraic Verification & Harmonic Analysis       ║"
  putStrLn "╚══════════════════════════════════════════════════════════╝"
  putStrLn ""

  -- Property verification
  putStrLn "── Ring Axiom Verification (exhaustive over Z/8Z) ─────────"
  putStrLn $ check "Associativity of ⊕ (addition)"      verifyAssocAdd
  putStrLn $ check "Additive identity (R0 = Kernel)"     verifyIdentityAdd
  putStrLn $ check "Additive inverses (∀a. a ⊕ -a = R0)" verifyInverseAdd
  putStrLn $ check "Commutativity of ⊕"                  verifyCommutAdd
  putStrLn $ check "Associativity of ⊗ (multiplication)" verifyAssocMul
  putStrLn $ check "Multiplicative identity (R1 = Task)"  verifyIdentityMul
  putStrLn $ check "Left distributivity"                  verifyDistribLeft
  putStrLn $ check "Right distributivity"                 verifyDistribRight
  putStrLn $ check "Commutativity of ⊗"                  verifyCommutMul
  putStrLn ""

  let allPass = and [ verifyAssocAdd, verifyIdentityAdd, verifyInverseAdd
                    , verifyCommutAdd, verifyAssocMul, verifyIdentityMul
                    , verifyDistribLeft, verifyDistribRight, verifyCommutMul ]
  putStrLn $ if allPass
    then "  ∴ Ring 0–7 is a commutative ring with unity. Q.E.D. ✨"
    else "  ⚠️  Some axioms failed!"
  putStrLn ""

  -- Inverse pairs
  putStrLn "── Additive Inverse Pairs (a ⊕ -a = R0) ──────────────────"
  mapM_ (\(a, b, interp) ->
    putStrLn $ "  " ++ show a ++ " ⊕ " ++ show b ++ " = R0  — " ++ interp
    ) inversePairs
  putStrLn ""

  -- Generators
  putStrLn "── Group Generators (orbit covers all of Z/8Z) ────────────"
  putStrLn $ "  Generators: " ++ intercalate ", " (map show generators)
  putStrLn "  (Elements coprime to 8: the odd rings generate all others)"
  putStrLn ""

  -- Sample orbits
  putStrLn "── Orbit of R3 (Prediction) ───────────────────────────────"
  putStrLn $ "  " ++ intercalate " → " (map show (orbit (mkRing 3)))
  putStrLn "  (Prediction cycles through: Prediction → Verification → Kernel → ...)"
  putStrLn ""

  -- Annihilators (zero divisors)
  putStrLn "── Zero Divisors (a ⊗ b = R0, a ≠ 0, b ≠ 0) ─────────────"
  if null annihilators
    then putStrLn "  (none — this would make Z/8Z an integral domain, but...)"
    else mapM_ (\(a, b) ->
      putStrLn $ "  " ++ show a ++ " ⊗ " ++ show b ++ " = R0"
      ) annihilators
  putStrLn "  (Zero divisors show which ring combinations 'cancel out'."
  putStrLn "   In SymbolOS: which layers, when multiplied, collapse to kernel.)"
  putStrLn ""

  -- Harmonic consonance matrix
  putStrLn "── Harmonic Consonance (distance ≤ 2) ─────────────────────"
  putStrLn "       R0  R1  R2  R3  R4  R5  R6  R7"
  mapM_ (\a -> do
    let row = map (\b ->
          if a == b then " · "
          else if isConsonant a b then " ♪ "
          else " · "
          ) allRings
    putStrLn $ "  " ++ show a ++ " " ++ concat row
    ) allRings
  putStrLn "  (♪ = consonant pair, · = dissonant)"
  putStrLn ""

  -- Ring model with meanings
  putStrLn "── The Ring Model ─────────────────────────────────────────"
  mapM_ (\r -> do
    let m = ringMeaning r
    putStrLn $ "  " ++ show r ++ " " ++ rmGlyph m ++ " " ++ rmLabel m
            ++ " [" ++ rmColor m ++ ", " ++ show (rmWavelength m) ++ "nm]"
            ++ "  — " ++ rmDescription m
    ) allRings
  putStrLn ""

  -- Rhy footer
  putStrLn "── 🦊 ─────────────────────────────────────────────────────"
  putStrLn "  \"They named it a ring model as a metaphor."
  putStrLn "   Then a fox ran the proofs and found it was true."
  putStrLn "   The metaphor didn't know it was literal."
  putStrLn "   Neither did the architects."
  putStrLn "   Gödel is laughing somewhere.\" — Rhy"
  putStrLn ""
