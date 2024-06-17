import requests
import pandas as pd
from bs4 import BeautifulSoup
import time
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator

def parse_actor_page(df, actor_directory):
    """
    Parses the acting credits of an actor given their directory on TMDB.
    
    Assumptions:
    - The page belongs to an actor with acting credits.
    - The acting credits are found in tables with the class 'credit_group'.

    Effect:
    - Navigates to the actor's page and extracts their name and acting credits.
    - Adds the extracted data to the DataFrame and removes duplicates.

    Args:
    df (pd.DataFrame): DataFrame to store the actor's credits.
    actor_directory (str): Directory of the actor on TMDB.

    Returns:
    pd.DataFrame: Updated DataFrame with the actor's credits.
    """
    base_url = f"https://www.themoviedb.org/person/{actor_directory}?credit_department=Acting"
    response = requests.get(base_url)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find the actor's name
    actor_name_tag = soup.find("h2", class_="title")
    if not actor_name_tag:
        print(f"No title tag found for {actor_directory}")
        return df

    actor_name = actor_name_tag.text.strip()
    print(f"Actor name: {actor_name}")

    # Find all acting credits sections
    acting_sections = soup.find_all('table', class_='credit_group')
    if not acting_sections:
        print(f"No acting sections found for {actor_name}")
        return df

    # Iterate over all acting sections and extract movie names
    for acting_section in acting_sections:
        rows = acting_section.find_all("tr")
        for row in rows:
            movie_name_tag = row.find("a")
            if movie_name_tag:
                movie_name = movie_name_tag.text.strip()
                print(f"Found movie/TV show: {movie_name}")
                new_row = pd.DataFrame({"actor": [actor_name], "movie_or_TV_name": [movie_name]})
                df = pd.concat([df, new_row], ignore_index=True)

    return df.drop_duplicates()

def parse_full_credits(movie_directory):
    """
    Parses the full cast credits of a movie given its directory on TMDB.
    
    Assumptions:
    - The page belongs to a movie with a full cast list.
    - The cast list is found in a section with the class 'panel pad'.

    Effect:
    - Navigates to the movie's cast page and extracts links to actor pages.
    - Calls parse_actor_page for each actor to get their acting credits.

    Args:
    movie_directory (str): Directory of the movie on TMDB.

    Returns:
    pd.DataFrame: DataFrame with all actors and their credits.
    """
    base_url = f"https://www.themoviedb.org/movie/{movie_directory}/cast"
    response = requests.get(base_url)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Find the cast section
    cast_section = soup.select_one("section.panel.pad:nth-of-type(1)")
    if not cast_section:
        print("Cast section not found.")
        return pd.DataFrame(columns=["actor", "movie_or_TV_name"])

    # Extract links to actor pages and remove duplicates
    actor_links = [a['href'] for a in cast_section.select("a[href*='/person/']")]
    actor_links = list(set(actor_links))

    print(f"Found {len(actor_links)} actors")

    df = pd.DataFrame(columns=["actor", "movie_or_TV_name"])

    # Parse each actor's page
    for actor_link in actor_links:
        actor_directory = actor_link.split('/')[-1]
        print(f"Parsing actor: {actor_directory}")
        df = parse_actor_page(df, actor_directory)
        time.sleep(1)  # To avoid getting blocked

    # Remove duplicates and sort the DataFrame
    df = df.drop_duplicates().sort_values(by=["actor", "movie_or_TV_name"]).reset_index(drop=True)

    return df