import 'package:customer/constant/constant.dart';
import 'package:customer/model/language_model.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SettingController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getLanguage();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<LanguageModel> languageList = <LanguageModel>[].obs;
  RxList<String> modeList = <String>['Light mode', 'Dark mode'].obs;
  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;
  Rx<String> selectedMode = "".obs;

  getLanguage() async {
    await FireStoreUtils.getLanguage().then((value) {
      if (value != null) {
        languageList.value = value;
        if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
          LanguageModel pref = Constant.getLanguage();

          for (var element in languageList) {
            if (element.id == pref.id) {
              selectedLanguage.value = element;
            }
          }
        }
      }
    });
    if (Preferences.getString(Preferences.themKey).toString().isNotEmpty) {
      selectedMode.value = Preferences.getString(Preferences.themKey).toString();
    } else {
      if (Get.isDarkMode == true) {
        selectedMode.value = 'Dark mode';
      } else {
        selectedMode.value = 'Light mode';
      }
    }
    isLoading.value = false;
    update();
  }

  Future<bool> deleteUserFromServer() async {
    var url = '${Constant.globalUrl}/api/delete-user';
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'uuid': FireStoreUtils.getCurrentUid(),
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
