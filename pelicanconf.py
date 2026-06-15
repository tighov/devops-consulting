AUTHOR = 'Tigran'
SITENAME = 'DevOps Consulting'
SITEURL = ''

PATH = 'content'
THEME = 'theme'

TIMEZONE = 'UTC'
DEFAULT_LANG = 'en'

# Contact form API endpoint (set to your deployed API Gateway URL)
LAMBDA_ENDPOINT = 'https://api.devops-consulting.link/contact-form'
COPYRIGHT_YEAR = '2025'

# Disable feeds for development
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Page settings
PAGE_URL = '{slug}/'
PAGE_SAVE_AS = '{slug}/index.html'
DISPLAY_PAGES_ON_MENU = False

# Disable blog-style features (this is a business site)
DIRECT_TEMPLATES = ['index']
ARTICLE_PATHS = []

# Static paths
STATIC_PATHS = ['images', 'extra']
EXTRA_PATH_METADATA = {
    'extra/robots.txt': {'path': 'robots.txt'},
}

DEFAULT_PAGINATION = False

# Menu items
MENUITEMS = (
    ('Home', '/'),
    ('Services', '/services/'),
    ('About', '/about/'),
    ('Book Now', '/book/'),
)

RELATIVE_URLS = True
