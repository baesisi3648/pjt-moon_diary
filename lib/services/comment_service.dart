import 'dart:math';

class CommentService {
  static final Random _random = Random();

  // F감성 코멘트 생성
  static String generateComment(String mood, String content) {
    final moodComments = _moodBasedComments[mood] ?? _moodBasedComments['neutral']!;
    final keywordComments = _analyzeContent(content);
    
    // 키워드 기반 코멘트가 있으면 우선 사용
    if (keywordComments.isNotEmpty) {
      return keywordComments[_random.nextInt(keywordComments.length)];
    }
    
    // 기분 기반 코멘트 반환
    return moodComments[_random.nextInt(moodComments.length)];
  }

  // 내용 분석해서 키워드 기반 코멘트 반환
  static List<String> _analyzeContent(String content) {
    final lowercaseContent = content.toLowerCase();
    final comments = <String>[];

    for (final entry in _keywordComments.entries) {
      for (final keyword in entry.key) {
        if (lowercaseContent.contains(keyword)) {
          comments.addAll(entry.value);
          break;
        }
      }
    }

    return comments;
  }

  // 기분별 코멘트
  static const Map<String, List<String>> _moodBasedComments = {
    'happy': [
      '오늘 하루 정말 행복했구나! 그 기쁨이 내일까지 이어지길 바라 💫',
      '행복한 하루였네! 이런 날들이 계속 이어지면 좋겠다 ✨',
      '웃는 날이 많았으면 좋겠어. 오늘처럼! 😊',
      '기분 좋은 날이네~ 이 행복 꼭 기억해두자 🌟',
      '행복한 순간들을 기록하는 너, 정말 멋져! 💕',
    ],
    'sad': [
      '힘든 하루였구나... 내일은 분명 더 좋은 날이 될 거야 🌙',
      '슬픈 날도 있는 거야. 그래도 이렇게 기록하는 너 정말 대단해 💙',
      '울고 싶을 땐 울어도 괜찮아. 내가 옆에 있을게 🤗',
      '지금은 힘들겠지만, 이 밤도 지나갈 거야. 푹 쉬어 🌠',
      '너의 마음이 조금이라도 가벼워지길 바라 💫',
    ],
    'angry': [
      '화나는 일이 있었구나. 그 감정 충분히 이해해 💪',
      '답답했겠다... 글로 풀어내서 조금은 나아졌으면 좋겠어 🍃',
      '화를 참지 않아도 돼. 느끼는 대로 느끼는 게 맞아 🔥',
      '내일은 오늘보다 더 평화로운 하루가 되길 바라 🌙',
      '힘든 감정도 지나갈 거야. 오늘 수고 많았어 ✨',
    ],
    'love': [
      '사랑으로 가득한 하루였네! 그 따뜻함이 느껴져 💕',
      '좋은 사람들과 함께한 시간, 정말 소중하지 🥰',
      '사랑받고 사랑하는 너, 정말 행복해 보여 💗',
      '이런 따뜻한 감정들이 계속 이어지길 바라 🌸',
      '사랑하는 마음을 가진 너, 정말 예뻐 💖',
    ],
    'sleepy': [
      '피곤했구나... 오늘 하루도 정말 수고 많았어 🌙',
      '푹 자고 내일 상쾌하게 일어나길! 좋은 꿈 꿔 ⭐',
      '일기 쓰느라 졸린 눈 비비면서 고생했네. 얼른 자자 😴',
      '오늘 하루 열심히 살았으니까 푹 쉬어도 돼 🛏️',
      '달콤한 꿈나라로 출발~! 좋은 밤 되길 🌠',
    ],
    'neutral': [
      '평범한 하루도 소중해. 기록해줘서 고마워 📝',
      '무난한 하루였구나. 내일은 어떤 하루가 될까? ✨',
      '그냥 그런 날도 있지. 그래도 수고했어 오늘 💫',
      '담담한 하루를 보냈네. 이런 날도 나쁘지 않아 🌙',
      '특별하지 않아도 괜찮아. 오늘도 잘 보냈으니까 🍃',
    ],
  };

  // 키워드별 코멘트
  static const Map<List<String>, List<String>> _keywordComments = {
    ['회사', '일', '업무', '출근', '퇴근', '야근']: [
      '오늘도 일하느라 수고 많았어! 푹 쉬어 💪',
      '열심히 일한 당신, 정말 멋져요 ✨',
      '일하는 너 정말 대단해. 오늘도 고생했어 🌟',
    ],
    ['친구', '만남', '약속', '수다']: [
      '좋은 사람들과 함께한 시간, 정말 소중하지 💕',
      '친구와의 시간이 즐거웠겠다! 좋은 추억이네 😊',
      '소중한 인연들을 잘 챙기는 너, 멋져 ✨',
    ],
    ['맛있', '먹었', '밥', '음식', '카페', '커피']: [
      '맛있는 거 먹으니까 행복하지? 나도 배고파진다 🍴',
      '오늘 뭐 먹었는지 궁금하네~ 맛있었길 바라! 😋',
      '맛있는 음식은 영혼을 치유해주지 💫',
    ],
    ['운동', '헬스', '러닝', '산책', '걷기']: [
      '건강 챙기는 너 정말 멋져! 오늘도 파이팅 💪',
      '운동하고 나면 기분이 좋아지지? 잘했어 🏃',
      '몸도 마음도 건강하게! 계속 화이팅 ✨',
    ],
    ['공부', '시험', '책', '독서', '학교', '수업']: [
      '열공하느라 수고했어! 분명 좋은 결과가 있을 거야 📚',
      '노력하는 너, 정말 멋져. 파이팅! ✏️',
      '공부도 좋지만 적당히 쉬어가면서 해 💪',
    ],
    ['가족', '엄마', '아빠', '부모님', '형', '누나', '동생']: [
      '가족과 함께한 시간, 정말 소중하지 💕',
      '가족이 있어서 참 다행이야. 따뜻한 하루였네 🏠',
      '사랑하는 가족들과 행복한 시간 보냈구나 💗',
    ],
    ['여행', '바다', '산', '풍경', '경치']: [
      '좋은 곳 다녀왔구나! 힐링됐겠다 🌊',
      '멋진 풍경을 봤네~ 눈이 호강했겠어 🏔️',
      '여행은 최고의 선물이야. 좋은 추억 만들었네 ✈️',
    ],
    ['실수', '잘못', '미안', '후회']: [
      '괜찮아, 누구나 실수할 수 있어. 너무 자책하지 마 💙',
      '실수도 성장의 일부야. 다음엔 더 잘할 수 있어 ✨',
      '지나간 일은 털어버리고 내일 다시 시작하자 🌱',
    ],
    ['감사', '고마', '행운', '다행']: [
      '감사한 마음을 가진 너, 정말 예뻐 💕',
      '좋은 일이 있었구나! 그 마음 오래오래 간직해 ✨',
      '감사할 줄 아는 사람에게 더 좋은 일이 찾아온대 🍀',
    ],
  };

  // 특별한 날 코멘트
  static String? getSpecialDayComment(DateTime date) {
    // 1년 전 같은 날
    if (date.month == DateTime.now().month && 
        date.day == DateTime.now().day &&
        date.year == DateTime.now().year - 1) {
      return '1년 전 오늘은 어떤 하루였을까? 시간이 참 빠르다 🕐';
    }
    
    // 새해
    if (date.month == 1 && date.day == 1) {
      return '새해 첫 일기네! 올해도 좋은 일만 가득하길 🎉';
    }
    
    // 크리스마스
    if (date.month == 12 && date.day == 25) {
      return '메리 크리스마스! 따뜻하고 행복한 하루 보내 🎄';
    }
    
    return null;
  }
}
