import re
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.corpus import wordnet as wn
from nltk.corpus import sentiwordnet as swn
from nltk.stem import PorterStemmer
from pprint import pprint as pp
lemmatizer = WordNetLemmatizer()



file_name = "sqoop_review.txt"
file_out_name = "sqoop_out.txt"
def penn_to_wn(tag):
    """
    Convert between the PennTreebank tags to simple Wordnet tags
    """
    if tag.startswith('J'):
        return wn.ADJ
    elif tag.startswith('N'):
        return wn.NOUN
    elif tag.startswith('R'):
        return wn.ADV
    elif tag.startswith('V'):
        return wn.VERB
    return None
def get_sentiment(word,tag):
    """ returns list of pos neg and objective score. But returns empty list if not present in senti wordnet. """

    wn_tag = penn_to_wn(tag)
    if wn_tag not in (wn.NOUN, wn.ADJ, wn.ADV):
        return []

    lemma = lemmatizer.lemmatize(word, pos=wn_tag)
    if not lemma:
        return []

    synsets = wn.synsets(word, pos=wn_tag)
    if not synsets:
        return []

    # Take the first sense, the most common
    synset = synsets[0]
    swn_synset = swn.senti_synset(synset.name())

    return [swn_synset.pos_score(),swn_synset.neg_score(),swn_synset.obj_score()]

def data_text_cleaning(data):

    # 영문자 이외의 문자는 공백으로 변환
    #data.rstrip('\n')
    #print(data)
    only_english = re.sub('[^a-zA-Z]', ' ', data)
    #print(len(only_english))

    # 소문자 변환
    no_capitals = only_english.lower().split()
    #print(no_capitals)

    # 불용어 제거
    stops = set(stopwords.words('english'))
    no_stops = [word for word in no_capitals if not word in stops]
    #print(stops)

    # 어간 추출 ???????
    stemmer = nltk.stem.SnowballStemmer('english')
    stemmer_words = [stemmer.stem(word) for word in no_stops]
    #print(stemmer_words)
    #print(len(stemmer_words))

    # 공백으로 구분된 문자열로 결합하여 결과 반환
    #return ' '.join(stemmer_words)

    return no_capitals




if __name__ == '__main__':
    file = open(file_name, 'r', encoding='ISO-8859-1')
    reviews = file.read()
    file.close()
    #cleaned_review = data_text_cleaning(reviews).split()
    cleaned_review = data_text_cleaning(reviews)
    print(cleaned_review)

    ps = PorterStemmer()
    pos_val = nltk.pos_tag(cleaned_review)
    senti_val = [get_sentiment(x, y) for (x, y) in pos_val]

    print(f"pos_val is {pos_val}")
    print(f"senti_val is {senti_val}")

    valid = 0
    invalid = 0
    pos = 0
    neg = 0
    obj = 0
    pos_score = 0
    neg_score = 0
    obj_score = 0
    pos_list = []
    neg_list= []

    # 0: pos, 1: neg, 2: obj

    for i in range(len(senti_val)):
        sent = senti_val[i]
        if len(sent) == 3:
            valid += 1
            pos_score += sent[0]
            neg_score += sent[1]
            obj_score += sent[2]
            M = max(sent[0], sent[1], sent[2])
            if sent[0] == M:
                pos += 1
                pos_list.append(pos_val[i][0])
            elif sent[1] == M:
                neg += 1
                neg_list.append(pos_val[i][0])
            else:
                obj += 1
        else:
            invalid += 1



    print("valid = "+str(valid)+", invalid = "+str(invalid))
    print("pos = "+str(pos)+", "+str(pos_score))
    print("neg = "+str(neg)+", "+str(neg_score))
    print("obj = "+str(obj)+", "+str(obj_score))
    print(pos_list)
    print(neg_list)

    p_num = []
    p_word = {}
    n_num = []
    n_word = {}

    for w in pos_list:
        if w in p_word:
            p_word[w] += 1
        else:
            p_word[w] = 1
    for w in neg_list:
        if w in n_word:
            n_word[w] += 1
        else:
            n_word[w] = 1
    p_word = sorted(p_word.items(), key=lambda x: x[1], reverse=True)
    n_word = sorted(n_word.items(), key=lambda x: x[1], reverse=True)
    pp(p_word)
    print("-------------------------")
    pp(n_word)


    file_out = open(file_out_name, 'w')
    file_out.write("pos_list\n")
    file_out.write(' '.join(pos_list))
    file_out.write('\n')
    file_out.write("neg_list\n")
    file_out.write(' '.join(neg_list))
    file_out.close()

