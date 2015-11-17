#include<cstdio>
#include<cstdlib>
#include<cstring>

// g++ shiritori.cc; time for var in {5..30}; do ./a.out $var; done
const char *KEN[] = {
"ほっかいどう","あおもり","いわて","あきた","みやぎ","やまがた","ふくしま",
"いばらき","とちき","くんま","ちは","さいたま","とうきょう","かながわ",
"やまなし","にいがた","とやま","いしかわ","ふくい","ながの","しずおか",
"あいち","きふ","しか","みえ","きょうと","なら","おおさか","わかやま",
"ひょうこ","おかやま","ひろしま","とっとり","しまね","やまぐち",
"かがわ","えひめ","こうち","とくしま","ふくおか","ながさき",
"おおいた","みやざき","さか","くまもと","かごしま","おきなわ"
};
const int L_KEN = 47;

bool next(char *s, bool *use, int remain) {
   int slen = strlen(s);
   for(int i = L_KEN - 1; i >= 0; i--) {
      if(use[i]) continue;
      if(s[slen - 1] == KEN[i][2] && s[slen - 2] == KEN[i][1]) {
         int tmplen = strlen(KEN[i]);
         if(tmplen == remain)
            return printf("%s%s\n", s, KEN[i]);
         else if(tmplen < remain) {
            char S[150];
            strcat(strcpy(S, s), KEN[i]);
            bool u[L_KEN];
            memcpy(u, use, sizeof(u));
            u[i] = true;
            if(next(S, u, remain - strlen(KEN[i]))) return true;
         }
      }
   }
   return false;
}

int main(int c, char **v) {
   if(c != 2) return printf("引数1個設定して下さい(自然数)\n");
   char s[150];
   for(int i = L_KEN - 1; i >= 0; i--) {
      bool u[L_KEN] = {false};
      u[i] = true;
      if(next(strcpy(s, KEN[i]), u, 3*atoi(v[1])-strlen(KEN[i])))return 0;
   }
   return printf("この組み合わせは見つかりませんでした\n");
}

