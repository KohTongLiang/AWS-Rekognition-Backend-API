import 'package:test/test.dart';
import 'package:frats_system_ase/utils/validator.dart';

void main() {

  ///Tests for email value
  group("Email: ", () {
    test('chsiao001@e.ntu.edu.sg', () {
      var result = Validator.validateEmail('chsiao001@e.ntu.edu.sg');
      expect(result, null);
    });

    // invalid
    test('empty string', () {
      var result = Validator.validateEmail('');
      expect(result, 'Enter Valid Email');
    });

    test('chsiao001', () {
      var result = Validator.validateEmail('chsiao001');
      expect(result, 'Enter Valid Email');
    });

    test('@e.ntu.edu.sg', () {
      var result = Validator.validateEmail('@e.ntu.edu.sg');
      expect(result, 'Enter Valid Email');
    });

    test('chiayu@ntu@edu.sg', () {
      var result = Validator.validateEmail('chiayu@ntu@edu.sg');
      expect(result, 'Enter Valid Email');
    });

    test('chiayu@ntu@edu.sg', () {
      var result = Validator.validateEmail('chiayu@ntu@edu.sg');
      expect(result, 'Enter Valid Email');
    });
  });

  /// Empty string tests
  group('Empty string: ', () {
    test('Hello world', () {
      var result = Validator.validateEmpty('Hello world');
      expect(result, null);
    });

    test('empty string', () {
      var result = Validator.validateEmpty('');
      expect(result, 'This field is required.');
    });
  });

  /// Test for Student Name value
  group('Student name: ', () {
    test('Chiayu', () {
      var result = Validator.validateStudentName('Chiayu');
      expect(result, null);
    });

    test('ChiaYu', () {
      var result = Validator.validateStudentName('ChiaYu');
      expect(result, null);
    });

    test('Hsiao Chia Yu', () {
      var result = Validator.validateStudentName('Hsiao Chia Yu');
      expect(result, null);
    });

    test('Hsiao Chia-Yu', () {
      var result = Validator.validateStudentName('Hsiao Chia-Yu');
      expect(result, null);
    });

    test('Koh Tat You @ Arthur Koh', () {
      var result = Validator.validateStudentName('Koh Tat You @ Arthur Koh');
      expect(result, null);
    });

    test('empty string', () {
      var result = Validator.validateStudentName('');
      expect(result, 'Enter Valid Student Name');
    });
  });

  /// Tests for Matric Number value
  group("Matric No: ", () {
    test('U0000000L', () {
      var result = Validator.validateMatricNo('U0000000L');
      expect(result, null);
    });

    test('u1811232s', () {
      var result = Validator.validateMatricNo('u1811232s');
      expect(result, null);
    });

    test('G1811133E', () {
      var result = Validator.validateMatricNo('G1811133E');
      expect(result, null);
    });

    test('T1772342P', () {
      var result = Validator.validateMatricNo('T1772342P');
      expect(result, null);
    });

    test('t1772342P', () {
      var result = Validator.validateMatricNo('t1772342P');
      expect(result, null);
    });

    test('g1772342P', () {
      var result = Validator.validateMatricNo('g1772342P');
      expect(result, null);
    });

    test('u1772342P', () {
      var result = Validator.validateMatricNo('U0000000L');
      expect(result, null);
    });

    test('X7126387X', () {
      var result = Validator.validateMatricNo('X7126387X');
      expect(result, 'Enter Valid Matriculation No.');
    });

    test('PPP', () {
      var result = Validator.validateMatricNo('PPP');
      expect(result, 'Enter Valid Matriculation No.');
    });

    test('empty string', () {
      var result = Validator.validateMatricNo('');
      expect(result, 'Enter Valid Matriculation No.');
    });

    test('1821839', () {
      var result = Validator.validateMatricNo('1821839');
      expect(result, 'Enter Valid Matriculation No.');
    });
  });

  /// Tests for Course Name
  group('Course Name: ', () {
    test('ASE', () {
      var result = Validator.validateCourseName('ASE');
      expect(result, null);
    });

    test('Software Systems Analysis and Design', () {
      var result =
          Validator.validateCourseName('Software Systems Analysis and Design');
      expect(result, null);
    });

    test('Adv. Software Engineering', () {
      var result = Validator.validateCourseName('Adv. Software Engineering');
      expect(result, null);
    });

    test('Sustainability: Seeing Through The Haze', () {
      var result = Validator.validateCourseName(
          'Sustainability: Seeing Through The Haze');
      expect(result, null);
    });

    test('Object Oriented Design & Programming', () {
      var result =
          Validator.validateCourseName('Object Oriented Design & Programming');
      expect(result, null);
    });

    test('Mathematics 101', () {
      var result = Validator.validateCourseName('Mathematics 101');
      expect(result, null);
    });

    test('Mathematics-and-Life', () {
      var result = Validator.validateCourseName('Mathematics-and-Life');
      expect(result, null);
    });

    test('Empty string', () {
      var result = Validator.validateCourseName('');
      expect(result, 'Enter Valid Course Name');
    });
  });

  /// Tests for course code value
  group('Course Code: ', () {
    test('CZ3002', () {
      var result = Validator.validateCourseCode('CZ3002');
      expect(result, null);
    });

    test('ce3005', () {
      var result = Validator.validateCourseCode('ce3005');
      expect(result, null);
    });

    test('empty string', () {
      var result = Validator.validateCourseCode('');
      expect(result, 'Enter Valid Course Code');
    });
  });

  /// Tests for academic year value
  group('Academic Year', () {
    test('AY1920S1', () {
      var result = Validator.validateAcadYear('AY1920S1');
      expect(result, null);
    });

    test('ay1920s1', () {
      var result = Validator.validateAcadYear('ay1920s1');
      expect(result, null);
    });

    test('empty string', () {
      var result = Validator.validateAcadYear('');
      expect(result, 'Enter Valid Academic Year');
    });

    test('ay20', () {
      var result = Validator.validateAcadYear('ay20');
      expect(result, 'Enter Valid Academic Year');
    });

    test('ay20s1', () {
      var result = Validator.validateAcadYear('ay20s1');
      expect(result, 'Enter Valid Academic Year');
    });

    test('AY20192020S2', () {
      var result = Validator.validateAcadYear('AY20192020S2');
      expect(result, 'Enter Valid Academic Year');
    });

    test('AY20192020Sem2', () {
      var result = Validator.validateAcadYear('AY20192020Sem2');
      expect(result, 'Enter Valid Academic Year');
    });
  });

  /// Tests for class name
  group('Class Name: ', () {
    test('SSP3', () {
      var result = Validator.validateClassName('SSP3');
      expect(result, null);
    });

    test('ss3', () {
      var result = Validator.validateClassName('ss3');
      expect(result, null);
    });

    test('FSP', () {
      var result = Validator.validateClassName('FSP');
      expect(result, 'Enter Valid Class Name');
    });

    test('SS', () {
      var result = Validator.validateClassName('SS');
      expect(result, 'Enter Valid Class Name');
    });

    test('TSR', () {
      var result = Validator.validateClassName('TSR');
      expect(result, 'Enter Valid Class Name');
    });

    test('TSP7', () {
      var result = Validator.validateClassName('TSP7');
      expect(result, null);
    });

    test('empty string', () {
      var result = Validator.validateClassName('');
      expect(result, 'Enter Valid Class Name');
    });
  });

  /// Test for time value
  group('Time: ', () {
    test('0830', () {
      var result = Validator.validateTime('0830');
      expect(result, null);
    });
    test('2359', () {
      var result = Validator.validateTime('0830');
      expect(result, null);
    });

    test('empty string', () {
      var result = Validator.validateTime('');
      expect(result, 'Enter Valid Time');
    });
    test('0860', () {
      var result = Validator.validateTime('2400');
      expect(result, 'Enter Valid Time');
    });
    test('2400', () {
      var result = Validator.validateTime('2400');
      expect(result, 'Enter Valid Time');
    });
  });
}
