---------------------------------
-- @name    LerMangasScaner 
-- @url     https://lermangas.me/
-- @author  YuuOrKillua
-- @license MIT
---------------------------------


---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }


----- IMPORTS -----
Html = require("html")
Headless = require('headless')
Time = require("time")
--- END IMPORTS ---



----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()
Base = "https://lermangas.me/"
Delay = 1 -- seconds
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query Query to search for
-- @return Table of tables with the following fields: name, url
function SearchManga(query)
    local url = Base .. "/?s=" .. query .. "&post_type=wp-manga"
    Page:navigate(url)
    Time.sleep(Delay)

    local mangas = {}

    for i, v in ipairs(Page:elements(".tab-thumb > a")) do
        local manga = { url = v:attribute('href'), name = v:attribute('title') }
        mangas[i + 1] = manga
    end

    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL URL of the manga
-- @return Table of tables with the following fields: name, url
function MangaChapters(mangaURL)
    Page:navigate(mangaURL)
    Time.sleep(Delay)

    local chapters = {}

    local n = 0
    for _, v in ipairs(Page:elements(".wp-manga-chapter > a")) do
        n = n + 1
        local elem = Html.parse(v:html())
        local link = elem:find("a"):first()

        local chapter = { url = link:attr("href"), name = link:find("a"):first():text()}

        if n ~= nil then
            chapters[n] = chapter
        end

    end

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL URL of the chapter
-- @return Table of tables with the following fields: url, index

function ChapterPages(chapterURL)
    Page:navigate(chapterURL)
    Time.sleep(Delay)

    local pages = {}
    local elements = Page:elements(".page-break img")
    local numPages = #elements

    for i, v in ipairs(elements) do
        local urlBrute = v:attribute("src")
        local _, startIndex = urlBrute:find('h')

        if startIndex then
            local urlClean = urlBrute:sub(startIndex)
            local p = { index = numPages - i + 1, url = urlClean }
            pages[i] = p
        end
    end

    return pages
end
--- END MAIN ---




----- HELPERS -----
--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
