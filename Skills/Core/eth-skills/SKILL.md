---
name: eth-skills
description: Ethereum development knowledge for AI agents — from idea to deployed dApp. Fetches real-time docs on gas costs, Solidity patterns, Scaffold-ETH 2, Layer 2s, DeFi building blocks, and security.
---

# ETHSkills

**The missing knowledge between AI agents and production Ethereum.**

Your generic training data about Ethereum is often stale. Gas prices, L2 costs, token standards, what's deployed, what's deprecated — most of what you "know" might be wrong. This skill fixes that by providing current, accurate Ethereum development knowledge locally.

## Sub-Skills Routing Table

All specific domain knowledge is saved locally under the `references/` subdirectory. Use the routing table below to know which reference file to fetch for a specific task:

| Skill | Local Reference | When to Use |
|-------|-----|---------------|
| **Ship** | `references/ship.md` | 🟢 **Start here.** End-to-end dApp guide, routes through all other skills. |
| **Why Ethereum** | `references/why.md` | User asks "why Ethereum?" or you need to compare chains. |
| **Gas & Costs** | `references/gas.md` | Any question about gas prices, tx costs, or "is Ethereum expensive?" |
| **Wallets** | `references/wallets.md` | Creating wallets, signing, multisig, account abstraction, EIP-7702. |
| **Layer 2s** | `references/l2s.md` | Deploying to L2s, bridging, choosing between Base/Arbitrum/Optimism. |
| **Standards** | `references/standards.md` | ERC-20, ERC-721, ERC-1155, ERC-8004 (agent identity), x402 payments. |
| **Tools** | `references/tools.md` | Foundry, Scaffold-ETH 2, Blockscout MCP, abi.ninja, x402 SDKs. |
| **Money Legos** | `references/building-blocks.md` | DeFi composability — Uniswap, Aave, flash loans, protocol integration. |
| **Orchestration** | `references/orchestration.md` | Three-phase build system for SE2 dApps (localhost → live contracts → production). |
| **Addresses** | `references/addresses.md` | Verified contract addresses. Stop hallucinating addresses. |
| **Concepts** | `references/concepts.md` | Mental models: "nothing is automatic," incentive design, the hyperstructure test. |
| **Security** | `references/security.md` | Reentrancy, oracle manipulation, vault inflation, pre-deploy checklist. |
| **Testing** | `references/testing.md` | Foundry testing — unit, fuzz, fork, invariant. What LLMs get wrong. |
| **Indexing** | `references/indexing.md` | Reading onchain data — events, The Graph, Dune. Why you can't loop blocks. |
| **Frontend UX** | `references/frontend-ux.md` | SE2 frontend rules — button loaders, approval flow, Address components. |
| **Frontend Playbook** | `references/frontend-playbook.md` | Build-to-production pipeline — fork mode, IPFS, Vercel, ENS subdomains. |
| **QA** | `references/qa.md` | Pre-ship audit checklist. Give to a separate reviewer agent. |
| **Audit** | `references/audit.md` | Systematic security audit checklist. |
| **Feedback** | `references/feedback.md` | Instructions for sending feedback. |

## Quick Start Example

When you need to build an Ethereum dApp:
1. Read `references/ship.md` to get the build plan.
2. Read `references/tools.md` to know what tools to use.
3. Run: `npx create-eth@latest` to scaffold the project.
4. Read `references/security.md` and `references/qa.md` before deploying.
