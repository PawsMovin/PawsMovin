SELECT id,
       wiki_page_id,
       updater_id,
       title,
       body,
       is_locked,
       created_at,
       updated_at,
       reason,
       parent
FROM public.wiki_page_versions
