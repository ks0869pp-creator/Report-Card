# Class Registration and Support Inbox

A browser-based registration page with a partner support inbox and help chat.

## Files

- `index.html` - registration page
- `support.html` - partner support inbox

## Run

Open `index.html` in a browser.

## Supabase setup

1. Run `supabase-setup.sql` in the Supabase SQL Editor.
2. In Supabase Authentication, create a partner user and disable public sign-ups.
3. Publish the latest `index.html` and `support.html` files.

Partner PDF uploads are stored in the `student-documents` bucket, and links are saved in `registrations.url`. The bucket is public so students can open documents from the registration page. Anyone who gets a document URL can view it; do not use this setup for confidential records.

## Note

Chat messages are still stored in browser local storage and are not shared between devices.