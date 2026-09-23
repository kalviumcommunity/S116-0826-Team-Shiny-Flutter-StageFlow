# StageSync Security & Authorization Model

This document outlines the security architecture and rules enforced across Cloud Firestore and Firebase Storage for the StageSync MVP.

---

## 1. Authentication & Roles
StageSync defines exactly two roles:
* **Director:** Responsible for creating and directing productions, scheduling rehearsals/auditions, and assigning cast.
* **Cast Member:** Participants who can view their production schedules, audition slots, and sign up for audition call times.

There is **no Administrator role** in the MVP scope.

---

## 2. Cloud Firestore Rules Breakdown (`firestore.rules`)

### `/users/{userId}`
* **Owner Access:** Users have full read/write privileges over their own profile document.
* **Cast Discovery Exception:** Authenticated users can read documents where `role == 'cast'`. This allows directors to populate cast assignment dropdowns without exposing any private data from non-cast users.

### `/productions/{prodId}`
* **Read Access:** Only users whose `uid` is included in the production's `memberIds` array can read the document.
* **Creation:** Only directors can create productions. When created, `memberIds` is strictly validated to contain only the director's own `uid`, preventing spoofed initial memberships.
* **Updates:** Directors can update any field (title, description, dates, poster). Production members are strictly permitted to update *only* the `memberIds` array (via diff checks) when joining via audition or role assignment.
* **Deletion:** Only the creating director can delete the production.

### `/productions/{prodId}/roles/{roleId}`
* **Read Access:** Any user in `memberIds`.
* **Write Access (Create/Update/Delete):** Only the production's director.

### `/productions/{prodId}/events/{eventId}`
* **Read Access:** Any user in `memberIds`.
* **Write Access:** Only the production's director.
* **Accepted Trust Boundary:** Event double-booking conflict detection runs client-side inside an atomic Firestore transaction. Because validating complex time intervals (`start < cand.end && end > cand.start`) across multiple documents is not possible inside security rules, this transaction acts as an accepted MVP client-side trust boundary.

### `/productions/{prodId}/auditions/{audId}`
* **Read Access:** Any user in `memberIds`.
* **Creation & Deletion:** Director only.
* **Update / Sign-up:** Directors can edit any field. Cast members can update the document **only** to add their own `uid` to the `castIds` array; they cannot remove others or modify dates/times.

---

## 3. Firebase Storage Rules Breakdown (`storage.rules`)

### `/posters/{prodId}.jpg`
* **Read Access:** Restricted to authenticated members of the production via `firestore.get()`. Posters are not public, protecting intellectual property and pre-release production artwork.
* **Write Access:** Restricted to the production's director.
* **Validation:** 
  * Maximum file size: **5 MB**.
  * Allowed MIME types: **`image/jpeg`** and **`image/png`** only.

---

## 4. Deployment Command
Deploy rules to your active Firebase project with:
```bash
firebase deploy --only firestore:rules,storage:rules
```
