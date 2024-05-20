SELECT id,
       creator_id,
       title,
       body,
       is_locked,
       created_at,
       updated_at,
       updater_id,
       parent
FROM public.wiki_pages
