using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.Rendering;

public class RampTexture : MonoBehaviour
{
    public List<Transform> ListButton;
    public MeshRenderer mesh;

    // Start is called before the first frame update
    void Start()
    {
        Init();
    }

    public void Init()
    {
        for(int i = 0 , ci = ListButton.Count; i < ci; i++)
        {
            ListButton[i].GetComponent<Button>().onClick.AddListener(ChangeTexture);
        }
    }

    private void ChangeTexture()
    {
        string textureName = EventSystem.current.currentSelectedGameObject.name;
        string dataPath = string.Format("Textures/{0}" ,textureName);
        Texture texture = Resources.Load(dataPath) as Texture;
        mesh.materials[0].SetTexture("_RampTex", texture);
    }

}
