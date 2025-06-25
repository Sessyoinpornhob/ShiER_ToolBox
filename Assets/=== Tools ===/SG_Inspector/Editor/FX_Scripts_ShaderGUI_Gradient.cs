#if UNITY_EDITOR

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class GradientGUI : ShaderGUI
{
    [GradientUsageAttribute(true)]
    public Gradient Gradient = new Gradient();
    List<string> HideInspectorList = new List<string>();
    GUIContent Label = new GUIContent();
    GUILayoutOption[] options;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        HideInspectorList.Clear(); //숨길 목록 초기화

        //Gradient = EditorGUILayout.GradientField(ShaderGUI.FindProperty("Color0", properties).displayName, Gradient);
        Label.text = ShaderGUI.FindProperty("Color0", properties).displayName; //그라데이션 프로퍼티 이름
        Gradient = EditorGUILayout.GradientField(Label, Gradient, true, options);

        //그라데이션 옵션이 초기 상태인지 확인
        if(
        Gradient.mode == GradientMode.Blend
        && Gradient.colorKeys.Length == 2
        && Gradient.colorKeys[0].color == new Color(1, 1, 1, 1)
        && Gradient.colorKeys[0].time == 0
        && Gradient.colorKeys[1].color == new Color(1, 1, 1, 1)
        && Gradient.colorKeys[1].time == 1
        && Gradient.alphaKeys.Length == 2 
        && Gradient.alphaKeys[0].alpha == 1
        && Gradient.alphaKeys[0].time == 0
        && Gradient.alphaKeys[1].alpha == 1
        && Gradient.alphaKeys[1].time == 1
        )
        {
            //머테리얼 값을 가져옴
            //Debug.Log("초기화 해야됨");
            GradientColorKey[] colorKeys = new GradientColorKey[(int)ShaderGUI.FindProperty("colorsLength", properties).floatValue]; //배열 추가
            GradientAlphaKey[] alphakeys = new GradientAlphaKey[(int)ShaderGUI.FindProperty("alphasLength", properties).floatValue]; //배열 추가
            Gradient.mode = ShaderGUI.FindProperty("type", properties).floatValue == 0 ? GradientMode.Blend : GradientMode.Fixed;
            
            for (int i = 0; i < colorKeys.Length; i++)
            {
                //Debug.Log(ShaderGUI.FindProperty("Color" + i.ToString(), properties).colorValue);
                colorKeys[i].color = ShaderGUI.FindProperty("Color" + i.ToString(), properties).colorValue;
                colorKeys[i].time = ShaderGUI.FindProperty("Color" + i.ToString(), properties).colorValue.a;
            }

            for (int i = 0; i < alphakeys.Length; i++)
            {
                alphakeys[i].alpha = ShaderGUI.FindProperty("Alpha" + i.ToString(), properties).vectorValue.x;
                alphakeys[i].time = ShaderGUI.FindProperty("Alpha" + i.ToString(), properties).vectorValue.y;
            }

            Gradient.SetKeys(colorKeys, alphakeys);
        }


        //그라에디션 데이터 업데이트
        MaterialProperty type = ShaderGUI.FindProperty("type", properties);
        HideInspectorList.Add("type");
        type.floatValue = (int)Gradient.mode;
        
        MaterialProperty colorsLength = ShaderGUI.FindProperty("colorsLength", properties);
        HideInspectorList.Add("colorsLength");
        colorsLength.floatValue = Gradient.colorKeys.Length;

        MaterialProperty alphasLength = ShaderGUI.FindProperty("alphasLength", properties);
        HideInspectorList.Add("alphasLength");
        alphasLength.floatValue = Gradient.alphaKeys.Length;

        for (int i = 0; i < Gradient.colorKeys.Length; i++)
        {
            MaterialProperty DrawColor = ShaderGUI.FindProperty("Color" + i.ToString(), properties);
            DrawColor.colorValue = new Vector4(Gradient.colorKeys[i].color.r, Gradient.colorKeys[i].color.g, Gradient.colorKeys[i].color.b, Gradient.colorKeys[i].time);
        }

        for (int i = 0; i < Gradient.alphaKeys.Length; i++)
        {
            MaterialProperty DrawAlpha = ShaderGUI.FindProperty("Alpha" + i.ToString(), properties);
            DrawAlpha.vectorValue = new Vector2(Gradient.alphaKeys[i].alpha, Gradient.alphaKeys[i].time);
        }

        //숨길 데이터 추가
        for (int i = 0; i < 8; i++)
        {
            HideInspectorList.Add("Color" + i.ToString());
            HideInspectorList.Add("Alpha" + i.ToString());
        }

        foreach (MaterialProperty property in properties)
        {
            bool HideTarget = false;
            foreach (var item in HideInspectorList)
            {
                if(property.name == item)
                {
                    HideTarget = true; //true일 경우 인스펙터에 출력하지 않습니다.
                    break;
                }
            }

            //숨길 타겟이 false면
            if(!HideTarget)
            {
                materialEditor.ShaderProperty(property, property.displayName); //그라데이션 관련 데이터를 제외한 모든 정보 출력
            }
        }
        //base.OnGUI (materialEditor, properties);
    }
}

#endif