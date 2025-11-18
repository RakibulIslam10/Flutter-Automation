#!/usr/bin/env bash
set -euo pipefail

echo "📁 Write YOUR CODE API End Point..."

BASE_DIR="lib/core/api/end_point"

# ✅ Ensure the directory exists
mkdir -p "$BASE_DIR"

# ✅ Write the ApiRequest class
cat > "$BASE_DIR/api_end_points.dart" <<'EOF'
class ApiEndPoints {
  static final mainDomain = 'http://13.62.165.184:3000';
  static final baseUrl = '$mainDomain/api/';

  // Auth
  static const login = 'auth/login';
  static const register = 'auth/register';
  static const verifyEmail = 'auth/verify-email';
  static const resendVerification = 'auth/resend-verification';
  static const resetPassword = 'auth/reset-password';
  static const forgotPassword = 'auth/forgot-password';

  //home
  static const banner = 'banner/get';
  static const privacy = 'manage/get-privacy-policy';
  static const terms = 'manage/get-terms-conditions';
  static const allEbookGet = 'ebooks/get';
  static const getAllBookCategory = 'book-categories/get';
  static const singlePost = 'home/book';

  //category
  static const categoryPreview = 'categories/books';
  static const getAllAudioBook = 'audio-books/get';
  static const faqGet = 'manage/get-faq';

  //profile
  static const changePassword = 'user/profile/change-password';
  static const profile = 'user/profile/get';
  static const updateProfile = 'user/profile/update';

  //bookmark
  static const bookMark = 'home/save';
  static const bookMarkData = 'home/saved';
  static const userProgress = 'user-progress/continue';
}

EOF

echo "╔════════════════════════════════════════════════════════════╗"
echo "      🚀✨ Successfully Write Api End Point Code 🎉           "
echo "╚════════════════════════════════════════════════════════════╝"
