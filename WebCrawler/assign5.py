import urllib.request
import re
from collections import defaultdict
import copy
from _operator import itemgetter
import csv

#Asif Jamal
#Note: Doesn't use concurrency so runs slow. Also no separate window graphics. 
class WebCrawler(object):
    
    def __init__(self, urls):
        self.linksMap = defaultdict(list); #Pages -> Links
        self.linkCounts = {};
        self.wordCounts = {};
        self.processFile(urls);
        self.crawlLinks();
        maxCount, links = self.countHighestLinks();
        self.writeToCSV(maxCount, links);
        self.sortedWordCounts = sorted(self.wordCounts.items(), key=itemgetter(1), reverse=True)
        self.shortSortedWordCounts = {};
        self.firstFifteenWords();
    
    # Takes a file of links and grabs all the links that start with 
    # http(s) from the pages of the given links. 
    def processFile(self, urls):
        file = open(urls);
        lines = file.read().splitlines(); #Handles /n char
        for line in lines: #Lines in file
            self.linksMap.setdefault(line, [])
            page = None;
            try: 
                page = urllib.request.urlopen(line);
            except urllib.error.HTTPError:
                continue
            except urllib.error.URLError:
                continue
            except urllib.error.ContentTooShortError:
                continue
            pageText = page.read();
            #Pulls html for links+words
            regex = '<a href {0,1}= {0,1}"http[s]{0,1}[^>]*>[^<]*</a>';
            links = re.findall(regex, str(pageText), re.IGNORECASE);
            for html in links: #Links+Words in html file
                link = re.findall('"([^"]*)"', html, re.IGNORECASE)[0];
                try:
                    text = re.findall(r'">([^<]*)</a>', html)[0];
                except IndexError:
                    continue;
                words = text.split();
                for word in words:
                    word = word.lower();
                    if (word in self.wordCounts):
                        num = self.wordCounts[word];
                        self.wordCounts[word] = num + 1;
                    else:
                        self.wordCounts[word] = 1;
                if (link not in self.linksMap[line]): #Avoid adding duplicates
                    self.linksMap[line].append(link);
                    #Finding the most linked link
                    if (link in self.linkCounts):
                        num = self.linkCount[link];
                        self.linkCounts[link] = num + 1;
                    else: 
                        self.linkCounts[link] = 1;
                
                        

    # Recursively crawls the stored links until 100 pages have been visited. 
    def crawlLinks(self):
        copyMap = copy.deepcopy(self.linksMap);
        values = copyMap.values();
        
        for value in values: #List of links for each page
            noKeys = True; #Stays true if all links exhausted
            for link in value: #Individual links(value) within stored Pages
                #Makes sure we don't keep checking the same pages(keys)
                if (link not in self.linksMap): 
                    self.linksMap.setdefault(link, []) #Adds new key w/ no Values 
                    page = None;
                    try: 
                        page = urllib.request.urlopen(link);
                    except urllib.error.HTTPError:
                        continue
                    except urllib.error.URLError:
                        continue
                    except urllib.error.ContentTooShortError:
                        continue
                    pageText = page.read();
                    regex = '<a href {0,1}= {0,1}"http[s]{0,1}[^>]*>[^<]*</a>';
                    newLinks = re.findall(regex, str(pageText), re.IGNORECASE);

                    for htmlLink in newLinks: #Goes over htmllink+text in new pages
                        newLink = re.findall('"([^"]*)"', htmlLink, re.IGNORECASE)[0]; #parses link   
                        try:
                            text = re.findall(r'">([^<]*)</a>', htmlLink)[0];
                        except IndexError:
                            continue;
                        words = text.split();
                        for word in words:
                            word = word.lower();
                            if (word in self.wordCounts):
                                num = self.wordCounts[word];
                                self.wordCounts[word] = num + 1;
                            else:
                                self.wordCounts[word] = 1;
                        if (newLink not in self.linksMap[link]): #Don't add same link as value twice
                            self.linksMap[link].append(newLink);
                            #Counting links
                            if (newLink in self.linkCounts):
                                num = self.linkCounts[newLink];
                                self.linkCounts[newLink] = num + 1;
                            else: 
                                self.linkCounts[link] = 1;
                            noKeys = False; #New keys to recurse over
                        if (len(self.linksMap.keys()) >= 100): 
                            return;
        if (len(self.linksMap.keys()) < 100 and noKeys == False):
            self.crawlLinks();
            
    # Finds the webpage with the highest number of links pointing to it. 
    def countHighestLinks(self):
        l = [];
        maxCount = 0;
        for v in self.linkCounts.values():
            if (v > maxCount):
                maxCount = v;
        for k,v in self.linkCounts.items():
            if (v == maxCount):
                l.append(k);
        maxCount = "Link Count: " + str(maxCount)
        return maxCount, l
        
    # Outputs page/links to csv file.
    def writeToCSV(self, maxCount, links):
        with open("crawl.csv", 'w') as f:
            writer = csv.writer(f)    
            for k,v in self.linksMap.items():
                writer.writerow([k] + v);
            writer.writerow([maxCount] + links);
                
    # Gets the first 15 word counts in desc order.
    def firstFifteenWords(self):
        count = 0;
        for k,v in self.sortedWordCounts:
            if (count > 14):
                break;
            else:
                self.shortSortedWordCounts[k] = v;
                count = count + 1;
        self.shortSortedWordCounts = sorted(self.shortSortedWordCounts.items(), key=itemgetter(1), reverse=True)
        print(self.shortSortedWordCounts);
        
          
    
        
            
        
                        
            
def mymain():

    WebCrawler("urls.txt");
  
if __name__ == '__main__':
    mymain()